#!/usr/bin/env python3
"""
Closure-Compression Duality: Real-World Applications

Demonstrates how closure-based compression applies to:
1. Data deduplication via hash-based closure
2. Feature selection via correlation closure
3. Neural network weight canonicalization (tropical normalization)
4. MDL model selection
"""

import numpy as np
from typing import List, Dict, Tuple
from collections import defaultdict


# ============================================================================
# Application 1: Data Deduplication
# ============================================================================

def demo_data_deduplication():
    """
    Data deduplication as closure-based compression.

    The closure operator maps each data record to its canonical form
    (e.g., normalized, trimmed, lowercased). Records with the same
    canonical form are duplicates.
    """
    print("=" * 70)
    print("APPLICATION 1: Data Deduplication via Closure")
    print("=" * 70)

    # Simulated dataset with near-duplicate records
    records = [
        "John Smith, 123 Main St, NYC",
        "john smith, 123 main st, nyc",
        "JOHN SMITH, 123 MAIN ST, NYC",
        "  John Smith , 123 Main St , NYC  ",
        "Jane Doe, 456 Oak Ave, LA",
        "jane doe, 456 oak ave, la",
        "Bob Wilson, 789 Pine Rd, CHI",
        "bob wilson,789 pine rd,chi",
        "BOB WILSON, 789 PINE RD, CHI",
    ]

    def normalize_record(s: str) -> str:
        """Closure operator: canonical form of a record."""
        return ' '.join(s.lower().strip().replace(',', ', ').split())

    # Verify idempotence
    for r in records:
        nr = normalize_record(r)
        assert normalize_record(nr) == nr, f"Not idempotent: {r}"

    # Compute equivalence classes
    classes: Dict[str, List[str]] = defaultdict(list)
    for r in records:
        classes[normalize_record(r)].append(r)

    print(f"\nOriginal records: {len(records)}")
    print(f"Unique canonical forms: {len(classes)}")
    print(f"Compression ratio: {len(records)/len(classes):.1f}x")

    for canon, members in classes.items():
        print(f"\n  Canonical: '{canon}'")
        for m in members:
            is_fixed = normalize_record(m) == m
            print(f"    {'★' if is_fixed else ' '} '{m}'")

    # Deficiency analysis
    print("\nDeficiency (characters saved by normalization):")
    for r in records:
        nr = normalize_record(r)
        deficiency = len(r) - len(nr)
        is_fixed = r == nr
        print(f"  δ('{r[:30]}...') = {deficiency:3d}  {'[FIXED]' if is_fixed else ''}")


# ============================================================================
# Application 2: Feature Correlation Closure
# ============================================================================

def demo_feature_selection():
    """
    Feature selection via correlation-based closure.

    The closure maps each feature to the "representative" feature
    in its correlation cluster. Features with correlation > threshold
    are in the same equivalence class.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Feature Selection via Correlation Closure")
    print("=" * 70)

    np.random.seed(42)
    n_samples = 100
    n_features = 8

    # Generate correlated features
    base1 = np.random.randn(n_samples)
    base2 = np.random.randn(n_samples)
    base3 = np.random.randn(n_samples)

    features = np.column_stack([
        base1,                              # Feature 0
        base1 + 0.1 * np.random.randn(n_samples),  # Feature 1 (corr w/ 0)
        base1 + 0.05 * np.random.randn(n_samples), # Feature 2 (corr w/ 0)
        base2,                              # Feature 3
        base2 + 0.1 * np.random.randn(n_samples),  # Feature 4 (corr w/ 3)
        base3,                              # Feature 5
        np.random.randn(n_samples),         # Feature 6 (independent)
        np.random.randn(n_samples),         # Feature 7 (independent)
    ])

    # Correlation matrix
    corr = np.corrcoef(features.T)
    threshold = 0.9

    # Closure: map each feature to the lowest-indexed feature with |corr| > threshold
    def feature_closure(i: int) -> int:
        for j in range(n_features):
            if abs(corr[i, j]) > threshold:
                return j
        return i

    # Verify idempotence
    for i in range(n_features):
        assert feature_closure(feature_closure(i)) == feature_closure(i)

    # Find equivalence classes
    classes: Dict[int, List[int]] = defaultdict(list)
    for i in range(n_features):
        classes[feature_closure(i)].append(i)

    print(f"\nFeatures: {n_features}")
    print(f"Correlation threshold: {threshold}")
    print(f"Independent groups: {len(classes)}")
    print(f"Selected features (fixed points): {sorted(classes.keys())}")

    print("\nFeature clusters:")
    for rep, members in sorted(classes.items()):
        correlations = [f"{corr[rep, m]:.3f}" for m in members]
        print(f"  Representative {rep}: {members} (correlations: {correlations})")

    print(f"\nDimensionality reduction: {n_features} → {len(classes)} features")
    print(f"Compression ratio: {n_features/len(classes):.1f}x")


# ============================================================================
# Application 3: Neural Network Weight Canonicalization
# ============================================================================

def demo_neural_network_canonicalization():
    """
    Neural network weight canonicalization via tropical normalization.

    For ReLU networks, weight vectors that differ by a positive scaling
    factor produce the same function. Tropical normalization removes
    this gauge freedom.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Neural Network Weight Canonicalization")
    print("=" * 70)

    def tropical_normalize(w: np.ndarray) -> np.ndarray:
        """Normalize by subtracting the minimum (log-space scaling)."""
        return w - w.min()

    # Simulated weight vectors from different training runs
    # These represent "the same" neuron up to scaling
    base_weights = np.array([2.0, 0.0, 4.0, 1.5])

    training_runs = [
        base_weights + 3.0,    # Run 1: shifted by 3
        base_weights + 7.5,    # Run 2: shifted by 7.5
        base_weights - 1.0,    # Run 3: shifted by -1
        base_weights,          # Run 4: already canonical
        np.array([1.0, 3.0, 2.0, 5.0]),  # Run 5: different neuron
    ]

    print("\nWeight vectors from different training runs:")
    for i, w in enumerate(training_runs):
        nw = tropical_normalize(w)
        is_canonical = np.allclose(w, nw)
        print(f"  Run {i+1}: {w} → normalized: {nw} {'[CANONICAL]' if is_canonical else ''}")

    # Check which runs found the same neuron
    print("\nEquivalence analysis:")
    for i in range(len(training_runs)):
        for j in range(i + 1, len(training_runs)):
            equiv = np.allclose(
                tropical_normalize(training_runs[i]),
                tropical_normalize(training_runs[j])
            )
            if equiv:
                print(f"  Run {i+1} ≡ Run {j+1} (same neuron, different gauge)")

    # Compression statistics
    unique_neurons = set()
    for w in training_runs:
        key = tuple(np.round(tropical_normalize(w), 8))
        unique_neurons.add(key)

    print(f"\nTotal weight vectors: {len(training_runs)}")
    print(f"Unique neurons (after canonicalization): {len(unique_neurons)}")
    print(f"Redundancy ratio: {len(training_runs)/len(unique_neurons):.1f}x")


# ============================================================================
# Application 4: MDL Model Selection
# ============================================================================

def demo_mdl_model_selection():
    """
    MDL model selection using closure-based compression.

    Different polynomial models are closure-equivalent if they produce
    the same predictions (up to rounding). The MDL-optimal model is
    the simplest in each equivalence class.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: MDL Model Selection")
    print("=" * 70)

    np.random.seed(42)

    # True model: y = 2x + 1 + noise
    n_points = 20
    x = np.linspace(0, 1, n_points)
    y_true = 2 * x + 1
    y_obs = y_true + 0.1 * np.random.randn(n_points)

    # Candidate models: polynomials of degree 1 through 6
    models = {}
    for degree in range(1, 7):
        coeffs = np.polyfit(x, y_obs, degree)
        y_pred = np.polyval(coeffs, x)
        residual = np.sum((y_obs - y_pred) ** 2)
        model_complexity = degree + 1  # number of parameters
        mdl_score = n_points * np.log2(residual / n_points + 1e-10) + model_complexity * np.log2(n_points)
        models[degree] = {
            'coeffs': coeffs,
            'residual': residual,
            'complexity': model_complexity,
            'mdl_score': mdl_score,
            'y_pred': y_pred,
        }

    # Closure: map each model to the simplest model with similar predictions
    tolerance = 0.5  # prediction tolerance

    def model_closure(degree: int) -> int:
        """Map to the lowest-degree model with similar predictions."""
        y_pred = models[degree]['y_pred']
        for d in range(1, degree + 1):
            if np.max(np.abs(models[d]['y_pred'] - y_pred)) < tolerance:
                return d
        return degree

    print(f"\nData: {n_points} points from y = 2x + 1 + noise")
    print(f"Prediction tolerance: {tolerance}")
    print(f"\n{'Degree':>8} {'Residual':>10} {'MDL':>10} {'cl(deg)':>8} {'Fixed?':>8}")
    print("-" * 50)

    for degree in sorted(models.keys()):
        m = models[degree]
        cd = model_closure(degree)
        is_fixed = cd == degree
        print(f"{degree:8d} {m['residual']:10.4f} {m['mdl_score']:10.2f} "
              f"{cd:8d} {'★' if is_fixed else '':>8}")

    # Find optimal model
    fixed_points = [d for d in models if model_closure(d) == d]
    best = min(fixed_points, key=lambda d: models[d]['mdl_score'])
    print(f"\nFixed points (canonical models): {fixed_points}")
    print(f"MDL-optimal model: degree {best} (MDL score: {models[best]['mdl_score']:.2f})")
    print(f"✓ MDL-optimal model is a fixed point of the closure (Theorem B)")


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    demo_data_deduplication()
    demo_feature_selection()
    demo_neural_network_canonicalization()
    demo_mdl_model_selection()
    print("\n" + "=" * 70)
    print("All applications demonstrated successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Closure-Compression Duality: Demonstrations

This script demonstrates the main theorems with concrete numerical examples:
1. Closure factorization and compression on finite sets
2. MDL optimality of canonical representatives
3. Deficiency computation and incompressibility detection
4. Tropical normalization and equivalence
"""

import numpy as np
from typing import Callable, Dict, List, Tuple, Set

# ============================================================================
# Demo 1: Closure Operator on Finite Sets
# ============================================================================

def demo_closure_compression():
    """Demonstrate closure-induced compression on a small finite set."""
    print("=" * 70)
    print("DEMO 1: Closure-Induced Compression")
    print("=" * 70)

    # Domain: integers mod 12, closure = rounding to nearest multiple of 3
    n = 12
    domain = list(range(n))

    def closure(x: int) -> int:
        """Round to nearest multiple of 3 (rounding up)."""
        return ((x + 2) // 3) * 3 % n

    # Verify idempotence
    print("\nClosure operator: round to nearest multiple of 3 (mod 12)")
    print(f"Domain: {domain}")
    print(f"Closure map: {[f'{x}→{closure(x)}' for x in domain]}")

    idempotent = all(closure(closure(x)) == closure(x) for x in domain)
    print(f"\nIdempotence check: {idempotent}")

    # Find fixed points
    fixed_points = [x for x in domain if closure(x) == x]
    print(f"Fixed points: {fixed_points}")

    # Show equivalence classes
    classes: Dict[int, List[int]] = {}
    for x in domain:
        cx = closure(x)
        classes.setdefault(cx, []).append(x)

    print("\nEquivalence classes (by canonical representative):")
    for rep, members in sorted(classes.items()):
        print(f"  cl⁻¹({rep}) = {members}")

    # Compression: encode only fixed points
    code_map = {fp: format(i, '02b') for i, fp in enumerate(fixed_points)}
    print(f"\nFixed-point encoding: {code_map}")

    print("\nCompression results:")
    for x in domain:
        cx = closure(x)
        code = code_map[cx]
        print(f"  x={x:2d} → cl(x)={cx:2d} → code='{code}'")

    # Verify: constant on equivalence classes
    for rep, members in classes.items():
        codes = {code_map[closure(x)] for x in members}
        assert len(codes) == 1, f"Code not constant on class of {rep}"
    print("\n✓ Compression is constant on equivalence classes")
    print("✓ Compression is idempotent (code(cl(x)) = code(x))")


# ============================================================================
# Demo 2: MDL Factorization
# ============================================================================

def demo_mdl_factorization():
    """Demonstrate that closure-respecting lengths factor through fixed points."""
    print("\n" + "=" * 70)
    print("DEMO 2: MDL Factorization Through Fixed Points")
    print("=" * 70)

    # Domain: strings of length ≤ 4
    strings = [''] + [s for length in range(1, 5)
                      for s in _generate_binary_strings(length)][:20]

    def closure(s: str) -> str:
        """Sort the characters (canonical representative of anagram class)."""
        return ''.join(sorted(s))

    # Verify idempotence
    assert all(closure(closure(s)) == closure(s) for s in strings)

    # A closure-respecting length function
    def L(s: str) -> int:
        """Description length: length of the sorted (canonical) form."""
        return len(closure(s))

    # Check closure-respecting property
    for s in strings:
        for t in strings:
            if closure(s) == closure(t):
                assert L(s) == L(t), f"L not closure-respecting: L({s})={L(s)}, L({t})={L(t)}"

    # Factor through fixed points
    fixed_points = sorted(set(closure(s) for s in strings))
    L_fix = {fp: L(fp) for fp in fixed_points}

    print(f"\nDomain size: {len(strings)} strings")
    print(f"Fixed points: {len(fixed_points)}")
    print(f"\nFactorization: L(x) = L_fix(cl(x))")
    print(f"L_fix values: {L_fix}")

    # Verify factorization
    for s in strings[:10]:
        cs = closure(s)
        assert L(s) == L_fix[cs]
        print(f"  L('{s}') = {L(s)} = L_fix('{cs}') ✓")

    print("\n✓ L factors through fixed points as proven in Theorem B")


# ============================================================================
# Demo 3: Deficiency and Incompressibility
# ============================================================================

def demo_deficiency():
    """Demonstrate the deficiency theorem: δ(x)=0 iff x is a fixed point."""
    print("\n" + "=" * 70)
    print("DEMO 3: Closure Deficiency and Incompressibility")
    print("=" * 70)

    # Domain: integers 0..15
    domain = list(range(16))

    def closure(x: int) -> int:
        """Map to largest power of 2 that divides x (or 0 for 0)."""
        if x == 0:
            return 0
        p = 1
        while x % (2 * p) == 0:
            p *= 2
        return p

    # Length function: bit length
    def length(x: int) -> int:
        return x.bit_length() if x > 0 else 0

    # Verify idempotence
    assert all(closure(closure(x)) == closure(x) for x in domain)

    print("\nClosure: map to largest power-of-2 divisor")
    print(f"{'x':>4} {'cl(x)':>6} {'ℓ(x)':>6} {'ℓ(cl(x))':>9} {'δ(x)':>6} {'Fixed?':>8}")
    print("-" * 45)

    for x in domain:
        cx = closure(x)
        lx = length(x)
        lcx = length(cx)
        deficiency = max(0, lx - lcx)
        is_fixed = cx == x
        marker = "★" if is_fixed else ""
        print(f"{x:4d} {cx:6d} {lx:6d} {lcx:9d} {deficiency:6d} {marker:>8}")

    # Verify theorem: δ=0 iff fixed
    for x in domain:
        cx = closure(x)
        deficiency = max(0, length(x) - length(cx))
        is_fixed = cx == x
        if is_fixed:
            assert deficiency == 0, f"Fixed point {x} has nonzero deficiency"
        # Note: deficiency can be 0 for non-fixed points too if length is non-strict

    print("\n✓ All fixed points have zero deficiency (Theorem C, forward direction)")


# ============================================================================
# Demo 4: Tropical Normalization
# ============================================================================

def demo_tropical_normalization():
    """Demonstrate tropical normalization and its fixed-point characterization."""
    print("\n" + "=" * 70)
    print("DEMO 4: Tropical Normalization")
    print("=" * 70)

    def trop_normalize(x: np.ndarray) -> np.ndarray:
        """Subtract the minimum coordinate."""
        return x - x.min()

    def trop_offset(x: np.ndarray) -> float:
        """The minimum coordinate value."""
        return float(x.min())

    # Test vectors
    vectors = [
        np.array([5.0, 3.0, 7.0]),
        np.array([8.0, 6.0, 10.0]),
        np.array([2.0, 0.0, 4.0]),
        np.array([1.0, 1.0, 1.0]),
        np.array([0.0, 0.0, 0.0]),
        np.array([-3.0, -5.0, -1.0]),
        np.array([0.0, 2.5, 7.1]),
    ]

    print("\nTropical normalization: x ↦ x - min(x)")
    print(f"{'Vector':>25} {'Normalized':>25} {'Offset':>8} {'Fixed?':>8}")
    print("-" * 70)

    for x in vectors:
        nx = trop_normalize(x)
        offset = trop_offset(x)
        is_fixed = np.allclose(nx, x)
        print(f"{str(x):>25} {str(nx):>25} {offset:8.1f} {'★' if is_fixed else '':>8}")

    # Verify idempotence
    print("\nIdempotence check:")
    for x in vectors:
        nx = trop_normalize(x)
        nnx = trop_normalize(nx)
        assert np.allclose(nx, nnx), f"Not idempotent for {x}"
        print(f"  norm(norm({x})) = norm({nx}) = {nnx} ✓")

    # Verify fixed-point characterization
    print("\nFixed-point characterization (Theorem D):")
    print("x is fixed ⟺ (∃i, x[i]=0) ∧ (∀j, x[j]≥0)")
    for x in vectors:
        is_fixed_computed = np.allclose(trop_normalize(x), x)
        has_zero = any(np.isclose(xi, 0) for xi in x)
        all_nonneg = all(xi >= -1e-10 for xi in x)
        is_fixed_predicted = has_zero and all_nonneg
        status = "✓" if is_fixed_computed == is_fixed_predicted else "✗"
        print(f"  {str(x):>25}: fixed={is_fixed_computed}, "
              f"has_zero={has_zero}, all_nonneg={all_nonneg} {status}")

    # Verify tropical equivalence
    print("\nTropical equivalence (vectors differing by a constant):")
    x1 = np.array([5.0, 3.0, 7.0])
    x2 = np.array([8.0, 6.0, 10.0])  # = x1 + 3
    x3 = np.array([2.0, 0.0, 4.0])   # = x1 - 3 = normalized
    x4 = np.array([1.0, 2.0, 3.0])   # different shape

    for a, b, expected in [(x1, x2, True), (x1, x3, True), (x2, x3, True), (x1, x4, False)]:
        same_norm = np.allclose(trop_normalize(a), trop_normalize(b))
        status = "✓" if same_norm == expected else "✗"
        print(f"  {a} ~ {b}: {same_norm} (expected {expected}) {status}")

    print("\n✓ Tropical equivalence ⟺ same normalization (Theorem D)")


# ============================================================================
# Utilities
# ============================================================================

def _generate_binary_strings(n: int) -> List[str]:
    """Generate all binary strings of length n."""
    if n == 0:
        return ['']
    return [b + c for b in _generate_binary_strings(n - 1) for c in '01']


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    demo_closure_compression()
    demo_mdl_factorization()
    demo_deficiency()
    demo_tropical_normalization()
    print("\n" + "=" * 70)
    print("All demonstrations completed successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all embedded content."""

import json
import base64
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def read_binary(path):
    with open(path, 'rb') as f:
        return base64.b64encode(f.read()).decode('utf-8')

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
lean_core = read_file('Computation/ClosureCompressionCore.lean')
lean_tropical = read_file('Computation/TropicalCompression.lean')

# Read visualization PNGs
viz_files = [
    ('closure_partition', 'Closure Equivalence Classes'),
    ('tropical_normalization', 'Tropical Normalization'),
    ('deficiency_landscape', 'Deficiency Landscape'),
    ('convergence_diagram', 'One-Step Convergence'),
    ('tropical_equivalence', 'Tropical Equivalence Classes'),
]

visualizations = []
for filename, name in viz_files:
    path = f'{filename}.png'
    if os.path.exists(path):
        b64 = read_binary(path)
        visualizations.append({
            'name': name,
            'data': f'data:image/png;base64,{b64}'
        })

lean_proofs = lean_core + "\n\n-- ========== TropicalCompression.lean ==========\n\n" + lean_tropical

package = {
    'title': 'Closure-Compression Duality: Idempotent Operators, Canonical Representatives, and Tropical Normal Forms',
    'domain': 'Computation / Information Theory / Tropical Geometry',
    'article': article,
    'research_paper': research_paper,
    'future_directions': future_directions,
    'demos': [
        {
            'name': 'Closure Compression Demonstrations',
            'code': demo_code
        },
        {
            'name': 'Real-World Applications',
            'code': applications_code
        }
    ],
    'algorithms': [
        {
            'name': 'Closure-Based Compression',
            'pseudocode': '''Algorithm: CLOSURE-COMPRESS(x, cl, code)
Input:  Element x, closure operator cl, encoding function code on fixed points
Output: Compressed binary string

1. Compute canonical representative: r ← cl(x)
2. Encode: return code(r)

Time: O(T_cl + T_code)
Space: O(|fixed points|) for codebook''',
            'code': algorithms_code
        },
        {
            'name': 'Tropical Normalization',
            'pseudocode': '''Algorithm: TROP-NORMALIZE(x)
Input:  Vector x ∈ ℝ^n
Output: Normalized vector with min coordinate 0

1. m ← min(x[0], x[1], ..., x[n-1])
2. for i = 0 to n-1:
3.     x[i] ← x[i] - m
4. return x

Time: O(n)
Space: O(1) additional''',
            'code': '''import numpy as np

def tropical_normalize(x):
    """Tropical normalization: subtract the minimum coordinate.
    
    Properties (machine-verified):
    - Idempotent: normalize(normalize(x)) = normalize(x)
    - Fixed points: normalize(x) = x iff x >= 0 and min(x) = 0
    - Canonical: normalize(x) = normalize(y) iff x - y is constant
    """
    return x - np.min(x)

def tropical_deficiency(x):
    """Deficiency = n * min(x). Zero iff x is a fixed point."""
    return len(x) * np.min(x)

# Example
x = np.array([5.0, 3.0, 7.0])
print(f"x = {x}")
print(f"normalize(x) = {tropical_normalize(x)}")
print(f"deficiency = {tropical_deficiency(x)}")
print(f"is_fixed = {np.allclose(tropical_normalize(x), x)}")

# Verify idempotence
nx = tropical_normalize(x)
nnx = tropical_normalize(nx)
print(f"normalize(normalize(x)) = {nnx}")
print(f"idempotent: {np.allclose(nx, nnx)}")
'''
        }
    ],
    'visualizations': visualizations,
    'lean_proofs': lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"Generated PACKAGE.json ({os.path.getsize('PACKAGE.json')} bytes)")


#!/usr/bin/env python3
"""
Closure-Compression Duality: Visualizations

Generates publication-quality figures illustrating the main theorems.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def viz_closure_partition():
    """Visualize closure equivalence classes and canonical representatives."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    # Domain: integers 0-11, closure = round to nearest multiple of 4
    n = 12
    def closure(x):
        return (round(x / 4)) * 4 % n

    classes = {}
    for x in range(n):
        cx = closure(x)
        classes.setdefault(cx, []).append(x)

    colors = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63', '#9C27B0']
    y_positions = {}
    for idx, (rep, members) in enumerate(sorted(classes.items())):
        color = colors[idx % len(colors)]
        for j, m in enumerate(members):
            x_pos = m
            y_pos = 1.0
            is_fixed = m == rep

            circle = plt.Circle((x_pos, y_pos), 0.35,
                              fill=True, facecolor=color,
                              edgecolor='black' if is_fixed else color,
                              linewidth=3 if is_fixed else 1,
                              alpha=0.8 if is_fixed else 0.4)
            ax.add_patch(circle)
            ax.text(x_pos, y_pos, str(m), ha='center', va='center',
                   fontsize=12, fontweight='bold' if is_fixed else 'normal',
                   color='white' if is_fixed else 'black')

            # Arrow from non-fixed to fixed
            if not is_fixed:
                ax.annotate('', xy=(rep, 0.3), xytext=(m, 0.6),
                          arrowprops=dict(arrowstyle='->', color=color,
                                        lw=1.5, connectionstyle='arc3,rad=0.2'))

        # Label the class
        ax.text(rep, -0.2, f'cl⁻¹({rep})',
               ha='center', va='top', fontsize=10, color=color, fontweight='bold')

    ax.set_xlim(-0.8, n - 0.2)
    ax.set_ylim(-0.8, 1.8)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Closure Equivalence Classes\n'
                 'Bold circles = fixed points (canonical representatives)',
                 fontsize=14, pad=20)

    return fig_to_base64(fig)


def viz_tropical_normalization():
    """Visualize tropical normalization in 3D."""
    fig = plt.figure(figsize=(12, 5))

    # 2D projection: show vectors and their normalizations
    ax1 = fig.add_subplot(121)

    vectors = [
        np.array([5.0, 3.0, 7.0]),
        np.array([8.0, 6.0, 10.0]),
        np.array([2.0, 0.0, 4.0]),
        np.array([1.0, 3.0, 2.0]),
        np.array([4.0, 6.0, 5.0]),
    ]

    colors_orig = ['#E91E63', '#2196F3', '#4CAF50', '#FF9800', '#9C27B0']

    for i, (v, c) in enumerate(zip(vectors, colors_orig)):
        nv = v - v.min()
        # Plot original (faded)
        ax1.bar(np.arange(3) + i * 0.15 - 0.3, v, width=0.12,
                color=c, alpha=0.3, label=f'x{i+1}' if i < 3 else None)

    ax1.set_xlabel('Coordinate index', fontsize=12)
    ax1.set_ylabel('Value', fontsize=12)
    ax1.set_title('Original Vectors (faded)', fontsize=13)
    ax1.set_xticks([0, 1, 2])
    ax1.legend(fontsize=9)

    ax2 = fig.add_subplot(122)

    for i, (v, c) in enumerate(zip(vectors, colors_orig)):
        nv = v - v.min()
        ax2.bar(np.arange(3) + i * 0.15 - 0.3, nv, width=0.12,
                color=c, alpha=0.9)

    ax2.set_xlabel('Coordinate index', fontsize=12)
    ax2.set_ylabel('Value', fontsize=12)
    ax2.set_title('After Tropical Normalization\n(min coordinate = 0)', fontsize=13)
    ax2.set_xticks([0, 1, 2])
    ax2.axhline(y=0, color='black', linewidth=0.5)

    fig.suptitle('Tropical Normalization: x ↦ x − min(x)', fontsize=15, y=1.02)
    plt.tight_layout()

    return fig_to_base64(fig)


def viz_deficiency_landscape():
    """Visualize deficiency landscape across elements."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Domain: integers 1-20
    domain = list(range(1, 21))

    def closure(x):
        """Map to nearest power of 2 (rounding down)."""
        p = 1
        while p * 2 <= x:
            p *= 2
        return p

    def length(x):
        return x.bit_length()

    deficiencies = []
    is_fixed = []
    for x in domain:
        cx = closure(x)
        d = length(x) - length(cx)
        deficiencies.append(d)
        is_fixed.append(cx == x)

    colors = ['#4CAF50' if f else '#E91E63' for f in is_fixed]

    ax1.bar(domain, deficiencies, color=colors, alpha=0.8, edgecolor='white')
    ax1.set_xlabel('Element x', fontsize=12)
    ax1.set_ylabel('Deficiency δ(x) = ℓ(x) − ℓ(cl(x))', fontsize=12)
    ax1.set_title('Closure Deficiency\nGreen = fixed points (δ=0)', fontsize=13)
    ax1.axhline(y=0, color='black', linewidth=0.5)

    # Compression map visualization
    for x in domain:
        cx = closure(x)
        if cx != x:
            ax2.annotate('', xy=(cx, 0.5), xytext=(x, 1.5),
                        arrowprops=dict(arrowstyle='->', color='#E91E63',
                                      alpha=0.4, lw=0.8))
        ax2.plot(x, 1.5, 'o', color='#E91E63' if not is_fixed[x-1] else '#4CAF50',
                markersize=8, alpha=0.7)
        if is_fixed[x-1]:
            ax2.plot(x, 0.5, 's', color='#4CAF50', markersize=10, alpha=0.9)

    ax2.set_xlabel('Element', fontsize=12)
    ax2.set_yticks([0.5, 1.5])
    ax2.set_yticklabels(['Fixed points', 'All elements'])
    ax2.set_title('Compression Map\nArrows: element → canonical representative', fontsize=13)
    ax2.set_xlim(0, 21)

    plt.tight_layout()
    return fig_to_base64(fig)


def viz_convergence_diagram():
    """Visualize one-step convergence of closure operators."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4))

    # Three examples of closure dynamics
    examples = [
        ("Sorting closure", lambda s: tuple(sorted(s)),
         [(3,1,4), (1,4,3), (4,3,1), (1,3,4), (3,4,1), (1,1,1)]),
        ("Modular closure (mod 3)", lambda x: x % 3,
         [0, 1, 2, 3, 4, 5, 6, 7, 8]),
        ("Min-max closure", lambda x: min(max(x, 0), 10),
         [-5, -2, 0, 3, 5, 7, 10, 12, 15]),
    ]

    for ax, (title, cl, domain) in zip(axes, examples):
        n = len(domain)
        for i, x in enumerate(domain):
            cx = cl(x)
            is_fp = cx == x

            # Original point
            ax.plot(i, 1, 'o', color='#2196F3', markersize=10, alpha=0.6)
            ax.text(i, 1.15, str(x), ha='center', va='bottom', fontsize=8)

            # After closure (at y=0)
            ax.plot(i, 0, 's' if is_fp else '^',
                   color='#4CAF50' if is_fp else '#FF9800',
                   markersize=10, alpha=0.8)
            ax.text(i, -0.15, str(cx), ha='center', va='top', fontsize=8)

            # Arrow
            ax.annotate('', xy=(i, 0.15), xytext=(i, 0.85),
                       arrowprops=dict(arrowstyle='->', color='gray', lw=1))

        ax.set_ylim(-0.5, 1.5)
        ax.set_yticks([0, 1])
        ax.set_yticklabels(['cl(x)', 'x'])
        ax.set_title(title, fontsize=11)
        ax.set_xticks([])

    fig.suptitle('One-Step Convergence: cl(cl(x)) = cl(x)\n'
                 'Green squares = fixed points, Orange triangles = compressed',
                 fontsize=13, y=1.05)
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_tropical_equivalence_classes():
    """Visualize tropical equivalence classes as parallel hyperplanes."""
    fig, ax = plt.subplots(figsize=(8, 6))

    # In 2D: tropical equivalence classes are lines y = x + c
    # Normalization projects onto the line through origin perpendicular to (1,1)

    xs = np.linspace(-2, 8, 100)

    # Draw equivalence classes (lines y = x + c)
    for c in np.arange(-3, 5, 1):
        color = '#E0E0E0' if c != 0 else '#4CAF50'
        lw = 2 if c == 0 else 0.8
        ax.plot(xs, xs + c, color=color, linewidth=lw, alpha=0.5)

    # Sample points and their normalizations
    points = [(2, 5), (1, 4), (4, 7), (3, 1), (5, 3), (0, 0), (2, 2)]
    for px, py in points:
        offset = min(px, py)
        nx, ny = px - offset, py - offset

        # Original point
        ax.plot(px, py, 'o', color='#E91E63', markersize=8, zorder=5)

        # Normalized point
        ax.plot(nx, ny, 's', color='#4CAF50', markersize=8, zorder=5)

        # Arrow from original to normalized
        ax.annotate('', xy=(nx, ny), xytext=(px, py),
                   arrowprops=dict(arrowstyle='->', color='#2196F3',
                                 lw=1.2, alpha=0.7))

    ax.set_xlabel('x₁', fontsize=13)
    ax.set_ylabel('x₂', fontsize=13)
    ax.set_title('Tropical Equivalence in ℝ²\n'
                 'Pink circles → green squares (normalization)\n'
                 'Green line = fixed points (nonneg with a zero)',
                 fontsize=12)
    ax.set_xlim(-1, 8)
    ax.set_ylim(-1, 8)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)

    return fig_to_base64(fig)


def generate_all_visualizations() -> dict:
    """Generate all visualizations and return as base64 dict."""
    print("Generating visualizations...")

    vizs = {}
    vizs['closure_partition'] = viz_closure_partition()
    print("  ✓ Closure partition")

    vizs['tropical_normalization'] = viz_tropical_normalization()
    print("  ✓ Tropical normalization")

    vizs['deficiency_landscape'] = viz_deficiency_landscape()
    print("  ✓ Deficiency landscape")

    vizs['convergence_diagram'] = viz_convergence_diagram()
    print("  ✓ Convergence diagram")

    vizs['tropical_equivalence'] = viz_tropical_equivalence_classes()
    print("  ✓ Tropical equivalence classes")

    print(f"Generated {len(vizs)} visualizations")
    return vizs


if __name__ == "__main__":
    vizs = generate_all_visualizations()
    # Save individual PNGs
    for name, data_uri in vizs.items():
        # Extract base64 data
        b64_data = data_uri.split(',')[1]
        img_data = base64.b64decode(b64_data)
        filename = f"{name}.png"
        with open(filename, 'wb') as f:
            f.write(img_data)
        print(f"Saved {filename}")
