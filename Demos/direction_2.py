#!/usr/bin/env python3
"""
Applications of Affine Distortion Complexity

Real-world applications showing how affine encodability provides
compression certificates for sensor data, financial data,
image processing, and scientific measurements.
"""

from fractions import Fraction
from typing import List
import math

# Import from algorithms
from algorithms import (
    compute_affine_encoding,
    minimum_bit_budget,
    compression_certificate,
    affine_distortion_ratio,
)


def application_sensor_compression():
    """
    Application 1: IoT Sensor Data Compression

    Temperature sensors typically output readings in a narrow range
    (e.g., 20-30°C) with fixed precision (e.g., 0.1°C resolution).
    Affine encodability provides a certified compression bound.
    """
    print("=" * 60)
    print("APPLICATION 1: IoT Sensor Data Compression")
    print("=" * 60)

    # Simulated temperature readings (°C × 10 for integer representation)
    readings = [Fraction(t, 10) for t in [201, 203, 205, 202, 204, 206, 203, 205,
                                           201, 207, 204, 202, 206, 205, 203, 201]]
    n = len(readings)
    cert = compression_certificate(readings)

    print(f"\nSensor readings (°C): {[float(x) for x in readings]}")
    print(f"Number of readings: {n}")
    print(f"Distinct values: {cert['n_distinct']}")
    print(f"Minimum bit budget: k = {cert['k_min']}")
    print(f"Affine code length: ≤ {cert['code_length_bound']} bits")
    print(f"Naive (12-bit ADC): {n * 12} bits")
    if cert['code_length_bound']:
        savings = n * 12 - cert['code_length_bound']
        print(f"Savings: {savings} bits ({100*savings/(n*12):.1f}%)")
    print(f"\nKey insight: The affine structure of sensor data guarantees")
    print(f"a compression ratio independent of the encoding scheme used.")


def application_financial_data():
    """
    Application 2: Financial Time Series Compression

    Stock prices often move in small increments (ticks) within a session.
    Affine normalization captures this regularity for certified compression.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Financial Time Series Compression")
    print("=" * 60)

    # Simulated stock prices in cents
    prices = [Fraction(p) for p in [10025, 10030, 10028, 10035, 10032,
                                     10040, 10038, 10042, 10045, 10041]]
    n = len(prices)
    cert = compression_certificate(prices)

    print(f"\nStock prices (cents): {[int(x) for x in prices]}")
    print(f"Price range: {int(min(prices))} - {int(max(prices))}")
    print(f"Minimum bit budget: k = {cert['k_min']}")
    print(f"Affine code length: ≤ {cert['code_length_bound']} bits")
    naive = n * 14  # 14 bits for prices up to ~16000
    print(f"Naive (14-bit): {naive} bits")
    if cert['code_length_bound']:
        savings = naive - cert['code_length_bound']
        print(f"Savings: {savings} bits ({100*savings/naive:.1f}%)")
    print(f"\nKey insight: Affine distortion captures the 'tick structure'")
    print(f"of financial data as a formal compressibility certificate.")


def application_image_quantization():
    """
    Application 3: Image Patch Quantization

    In image compression, patches with smooth gradients have low
    affine distortion and can be efficiently quantized.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Image Patch Quantization")
    print("=" * 60)

    # Smooth gradient patch (8 pixels)
    gradient = [Fraction(i * 32 + 16) for i in range(8)]
    cert_smooth = compression_certificate(gradient)

    # Random-looking patch
    noisy = [Fraction(x) for x in [23, 187, 42, 201, 5, 156, 89, 244]]
    cert_noisy = compression_certificate(noisy)

    print(f"\nSmooth gradient: {[int(x) for x in gradient]}")
    print(f"  Distortion ratio: {cert_smooth['distortion_ratio']}")
    print(f"  Min bit budget: k = {cert_smooth['k_min']}")
    print(f"  Code length: ≤ {cert_smooth['code_length_bound']} bits")

    print(f"\nNoisy patch: {[int(x) for x in noisy]}")
    print(f"  Distortion ratio: {cert_noisy['distortion_ratio']}")
    print(f"  Min bit budget: k = {cert_noisy['k_min']}")
    print(f"  Code length: ≤ {cert_noisy['code_length_bound']} bits")

    print(f"\nKey insight: Low affine distortion identifies patches amenable to")
    print(f"efficient encoding — this is a geometric complexity classifier.")


def application_mdl_model_selection():
    """
    Application 4: MDL Model Selection

    Affine distortion provides a principled model selection criterion:
    datasets with low affine distortion have short descriptions under
    the affine model class, making them MDL-favored.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: MDL Model Selection via Affine Distortion")
    print("=" * 60)

    # Model 1: Linear data (low distortion)
    linear_data = [Fraction(3 * i + 7) for i in range(10)]
    cert_linear = compression_certificate(linear_data)

    # Model 2: Quadratic data (higher distortion)
    quadratic_data = [Fraction(i * i) for i in range(10)]
    cert_quad = compression_certificate(quadratic_data)

    # Model 3: Arithmetic progression with large common difference
    arith_data = [Fraction(100 * i + 1) for i in range(10)]
    cert_arith = compression_certificate(arith_data)

    print(f"\nLinear data (3i+7): {[int(x) for x in linear_data]}")
    print(f"  k_min = {cert_linear['k_min']}, code length ≤ {cert_linear['code_length_bound']}")
    print(f"  Distortion ratio: {cert_linear['distortion_ratio']}")

    print(f"\nQuadratic data (i²): {[int(x) for x in quadratic_data]}")
    print(f"  k_min = {cert_quad['k_min']}, code length ≤ {cert_quad['code_length_bound']}")
    print(f"  Distortion ratio: {cert_quad['distortion_ratio']}")

    print(f"\nArithmetic (100i+1): {[int(x) for x in arith_data]}")
    print(f"  k_min = {cert_arith['k_min']}, code length ≤ {cert_arith['code_length_bound']}")
    print(f"  Distortion ratio: {cert_arith['distortion_ratio']}")

    print(f"\nKey insight: MDL selects models that yield short descriptions.")
    print(f"Affine distortion is a geometric proxy for description length")
    print(f"under affine model classes — it makes MDL geometrically interpretable.")


def application_scientific_measurement():
    """
    Application 5: Scientific Measurement Compression

    Calibrated scientific instruments produce data with known affine
    relationships to physical quantities. Affine encodability captures
    this calibration structure.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 5: Scientific Measurement Compression")
    print("=" * 60)

    # Thermistor readings (resistance in ohms, linearly related to temp)
    # R = 1000 + 4 * T, T in {20, 21, ..., 30}
    resistances = [Fraction(1000 + 4 * t) for t in range(20, 31)]
    cert = compression_certificate(resistances)

    print(f"\nThermistor resistances (Ω): {[int(x) for x in resistances]}")
    print(f"  Underlying: R = 1000 + 4T, T ∈ {{20,...,30}}")
    print(f"  k_min = {cert['k_min']}")
    print(f"  Code length: ≤ {cert['code_length_bound']} bits")
    print(f"  Distortion ratio: {cert['distortion_ratio']}")

    # The affine structure perfectly captures the calibration
    enc = compute_affine_encoding(resistances, cert['k_min'])
    if enc:
        print(f"  Affine recovery: a = {float(enc.a):.4f}, b = {float(enc.b):.4f}")
        print(f"  Quantized: {enc.quantized}")

    print(f"\nKey insight: Physical calibration curves are affine transformations.")
    print(f"Affine encodability certifies that calibrated data compresses optimally.")


if __name__ == "__main__":
    application_sensor_compression()
    application_financial_data()
    application_image_quantization()
    application_mdl_model_selection()
    application_scientific_measurement()

    print("\n" + "=" * 60)
    print("All applications completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demo: Affine Distortion as a Complexity Monotone

Concrete numerical examples illustrating how affine encodability
yields compression and entropy bounds on finite datasets.
"""

from fractions import Fraction
from typing import List
import math

from algorithms import (
    compute_affine_encoding,
    minimum_bit_budget,
    compression_certificate,
)


def demo_basic():
    """Basic demonstration of affine encodability."""
    print("=" * 60)
    print("DEMO 1: Basic Affine Encodability")
    print("=" * 60)

    # Example 1: [0, 1, 2, 3] with k=2
    xs = [Fraction(i) for i in [0, 1, 2, 3]]
    k = 2
    result = compute_affine_encoding(xs, k)
    print(f"\nDataset: {[float(x) for x in xs]}")
    print(f"Bit budget k = {k}")
    if result:
        print(f"Affine parameters: a = {result.a}, b = {result.b}")
        print(f"Quantized values: {result.quantized}")
        print(f"Code length bound: {result.code_length_bound} bits")
        print(f"Entropy bound: {result.entropy_bound} bits")
    print()

    # Example 2: [0, 1/2, 1] with k=2
    xs = [Fraction(0), Fraction(1, 2), Fraction(1)]
    k = 2
    result = compute_affine_encoding(xs, k)
    print(f"Dataset: {[float(x) for x in xs]}")
    print(f"Bit budget k = {k}")
    if result:
        print(f"Affine parameters: a = {result.a}, b = {result.b}")
        print(f"Quantized values: {result.quantized}")
        print(f"Code length bound: {result.code_length_bound} bits")
        print(f"Entropy bound: {result.entropy_bound} bits")
    print()

    # Example 3: [10, 20, 30, 40, 50]
    xs = [Fraction(i) for i in [10, 20, 30, 40, 50]]
    k_min = minimum_bit_budget(xs)
    result = compute_affine_encoding(xs, k_min)
    print(f"Dataset: {[float(x) for x in xs]}")
    print(f"Minimum bit budget: k = {k_min}")
    if result:
        print(f"Affine parameters: a = {float(result.a):.4f}, b = {float(result.b):.4f}")
        print(f"Quantized values: {result.quantized}")
        print(f"Code length bound: {result.code_length_bound} bits")
        print(f"Entropy bound: {result.entropy_bound} bits")


def demo_permutation_invariance():
    """Demonstrate that affine encodability is permutation-invariant."""
    print("\n" + "=" * 60)
    print("DEMO 2: Permutation Invariance")
    print("=" * 60)

    import random
    random.seed(42)

    xs = [Fraction(i) for i in [3, 1, 4, 1, 5, 9, 2, 6]]
    k_original = minimum_bit_budget(xs)

    print(f"\nOriginal: {[int(x) for x in xs]}")
    print(f"Minimum bit budget: {k_original}")

    for trial in range(5):
        perm = xs[:]
        random.shuffle(perm)
        k_perm = minimum_bit_budget(perm)
        status = "✓" if k_perm == k_original else "✗"
        print(f"Permutation {trial+1}: {[int(x) for x in perm]} → k = {k_perm} {status}")


def demo_monotonicity():
    """Demonstrate monotonicity in bit budget."""
    print("\n" + "=" * 60)
    print("DEMO 3: Monotonicity in Bit Budget")
    print("=" * 60)

    xs = [Fraction(i) for i in [0, 7, 15, 31]]
    k_min = minimum_bit_budget(xs)
    print(f"\nDataset: {[int(x) for x in xs]}")
    print(f"Minimum bit budget: {k_min}")

    for k in range(1, k_min + 4):
        result = compute_affine_encoding(xs, k)
        encodable = result is not None
        cl = result.code_length_bound if result else 0
        print(f"  k = {k}: {'encodable ✓' if encodable else 'not encodable ✗'}"
              + (f"  (code length ≤ {cl} bits)" if encodable else ""))


def demo_compression_pipeline():
    """Full pipeline: affine distortion → compression → entropy."""
    print("\n" + "=" * 60)
    print("DEMO 4: Full Compression Pipeline")
    print("=" * 60)

    datasets = [
        ("Temperatures (°F)", [Fraction(i) for i in [68, 72, 71, 69, 73, 70, 74]]),
        ("Stock prices ($)", [Fraction(i) for i in [100, 102, 98, 105, 101, 99, 103, 104]]),
        ("Sensor readings", [Fraction(i, 10) for i in [33, 34, 35, 33, 36, 34, 35]]),
        ("Pixel values", [Fraction(i) for i in [0, 51, 102, 153, 204, 255]]),
    ]

    for name, xs in datasets:
        cert = compression_certificate(xs)
        n = len(xs)
        k = cert['k_min']

        print(f"\n{name}: {[float(x) for x in xs]}")
        print(f"  n = {n}, k_min = {k}")
        if cert['code_length_bound']:
            naive = cert['naive_bits']
            cl = cert['code_length_bound']
            eb = cert['entropy_bound']
            savings = max(0, naive - cl)
            print(f"  Quantized: {cert['encoding'].quantized}")
            print(f"  Code length bound: {cl} bits")
            print(f"  Entropy bound: {eb} bits")
            print(f"  Naive encoding: ~{naive} bits")
            print(f"  Savings: ~{savings} bits ({100*savings/max(naive,1):.0f}%)")


def demo_distinct_values():
    """Demonstrate the distinct values bound."""
    print("\n" + "=" * 60)
    print("DEMO 5: Distinct Values Bound")
    print("=" * 60)

    xs = [Fraction(i) for i in [1, 2, 3, 2, 1, 3, 2, 1]]
    distinct = len(set(xs))
    k = minimum_bit_budget(xs)

    print(f"\nDataset: {[int(x) for x in xs]}")
    print(f"Total elements: {len(xs)}")
    print(f"Distinct values: {distinct}")
    print(f"Minimum bit budget: k = {k}")
    print(f"Bound 2^k = {2**k}")
    assert distinct <= 2**k, "VIOLATION!"
    print(f"Distinct ≤ 2^k: {distinct} ≤ {2**k} ✓")


if __name__ == "__main__":
    demo_basic()
    demo_permutation_invariance()
    demo_monotonicity()
    demo_compression_pipeline()
    demo_distinct_values()
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts."""

import json
import sys
sys.path.insert(0, '.')

from visualizations import (
    viz_affine_encoding,
    viz_compression_pipeline,
    viz_distinct_values_bound,
    viz_permutation_invariance,
)

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
lean_code = read_file('Computation/AffineDistortionComplexity.lean')

# Generate visualizations
print("Generating visualizations for PACKAGE.json...")
viz1 = viz_affine_encoding()
viz2 = viz_compression_pipeline()
viz3 = viz_distinct_values_bound()
viz4 = viz_permutation_invariance()

# Build package
package = {
    "title": "Affine Distortion as a Complexity Monotone",
    "domain": "Computation",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Affine Encodability Demo",
            "code": demo_code.replace("from algorithms import", "# Note: algorithms module imported below\n# In standalone mode, copy algorithms.py content here\nfrom algorithms import")
        },
        {
            "name": "Applications Demo",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Affine Encoding Algorithm",
            "pseudocode": """function COMPUTE_AFFINE_ENCODING(xs: List[Q], k: N) -> Option[AffineEncoding]:
    if xs is empty: return (1, 0, [])
    x_min <- min(xs), x_max <- max(xs)
    if x_min = x_max: return (1, -x_min, [0, ..., 0])
    diffs <- {x - x_min : x in set(xs), x != x_min}
    g <- GCD(diffs)
    n_steps <- (x_max - x_min) / g
    if n_steps > 2^k - 1: return None
    a <- 1/g, b <- -a * x_min
    quantized <- [a * x + b for x in xs]
    return AffineEncoding(a, b, k, quantized)""",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {"name": "Affine Encoding Process", "data": viz1},
        {"name": "Compression Bounds vs Data Spread", "data": viz2},
        {"name": "Distinct Values Bound", "data": viz3},
        {"name": "Permutation Invariance", "data": viz4},
    ],
    "lean_proofs": lean_code,
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({len(json.dumps(package))} chars)")


#!/usr/bin/env python3
"""
Visualizations for Affine Distortion Complexity

Generates publication-quality figures showing the relationship
between affine distortion, compression, and entropy bounds.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from fractions import Fraction
import base64
import io

from algorithms import (
    compute_affine_encoding,
    minimum_bit_budget,
    compression_certificate,
    affine_distortion_ratio,
)


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_affine_encoding():
    """Visualize affine encoding: original data → quantized grid."""
    fig, axes = plt.subplots(1, 3, figsize=(14, 4))

    # Dataset
    xs = [Fraction(i) for i in [10, 20, 30, 40, 50]]
    xs_float = [float(x) for x in xs]

    # Plot 1: Original data on number line
    ax = axes[0]
    ax.scatter(xs_float, [0]*len(xs_float), s=100, c='steelblue', zorder=5)
    ax.set_xlim(5, 55)
    ax.set_ylim(-0.5, 0.5)
    ax.set_title('Original Data', fontsize=13, fontweight='bold')
    ax.set_xlabel('Value')
    ax.axhline(y=0, color='gray', linewidth=0.5)
    ax.set_yticks([])
    for x in xs_float:
        ax.annotate(f'{int(x)}', (x, 0.08), ha='center', fontsize=10)

    # Plot 2: Affine transformation
    enc = compute_affine_encoding(xs, 3)
    ax = axes[1]
    for i, (x, n) in enumerate(zip(xs_float, enc.quantized)):
        ax.annotate('', xy=(n, -0.3), xytext=(x/10 - 1, 0.3),
                     arrowprops=dict(arrowstyle='->', color='coral', lw=1.5))
    ax.scatter([x/10 - 1 for x in xs_float], [0.3]*len(xs_float), s=80, c='steelblue', zorder=5)
    ax.scatter(enc.quantized, [-0.3]*len(enc.quantized), s=80, c='coral', zorder=5, marker='s')
    ax.set_title('Affine Map: x ↦ x/10 − 1', fontsize=13, fontweight='bold')
    ax.set_xlim(-1.5, 5.5)
    ax.set_ylim(-0.6, 0.6)
    ax.set_yticks([])
    ax.axhline(y=0.3, color='steelblue', linewidth=0.5, alpha=0.3)
    ax.axhline(y=-0.3, color='coral', linewidth=0.5, alpha=0.3)

    # Plot 3: Quantized integers in bounded grid
    ax = axes[2]
    grid_size = 8  # 2^3
    ax.set_xlim(-0.5, grid_size - 0.5)
    ax.set_ylim(-0.5, 0.5)
    for i in range(grid_size):
        color = 'coral' if i in enc.quantized else 'lightgray'
        ax.scatter([i], [0], s=100, c=color, marker='s', zorder=5,
                   edgecolors='black' if i in enc.quantized else 'gray')
    ax.set_title(f'Quantized Grid {{0,...,{grid_size-1}}}', fontsize=13, fontweight='bold')
    ax.set_xlabel('Quantized Value')
    ax.set_xticks(range(grid_size))
    ax.set_yticks([])
    ax.axhline(y=0, color='gray', linewidth=0.5)

    plt.tight_layout()
    return fig_to_base64(fig)


def viz_compression_pipeline():
    """Visualize the compression pipeline: distortion → code length → entropy."""
    fig, ax = plt.subplots(figsize=(10, 5))

    # Generate datasets with varying structure
    datasets = []
    for spread in range(1, 20):
        xs = [Fraction(i * spread) for i in range(10)]
        k = minimum_bit_budget(xs)
        n = len(xs)
        datasets.append({
            'spread': spread,
            'distortion': float(affine_distortion_ratio(xs)),
            'k_min': k,
            'code_length': n * k + k,
            'entropy': n * k,
        })

    spreads = [d['spread'] for d in datasets]
    code_lengths = [d['code_length'] for d in datasets]
    entropy_bounds = [d['entropy'] for d in datasets]
    k_mins = [d['k_min'] for d in datasets]

    ax.plot(spreads, code_lengths, 'o-', color='steelblue', label='Code length bound', linewidth=2)
    ax.plot(spreads, entropy_bounds, 's--', color='coral', label='Entropy bound', linewidth=2)
    ax.bar(spreads, k_mins, alpha=0.2, color='green', label='Min bit budget k')

    ax.set_xlabel('Step size (spread)', fontsize=12)
    ax.set_ylabel('Bits', fontsize=12)
    ax.set_title('Compression Bounds vs. Data Spread\n(10 evenly-spaced values with varying step size)',
                  fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    return fig_to_base64(fig)


def viz_distinct_values_bound():
    """Visualize the distinct values bound: |dedup| ≤ 2^k."""
    fig, ax = plt.subplots(figsize=(8, 5))

    # Vary number of distinct values
    results = []
    for n_distinct in range(1, 33):
        xs = [Fraction(i) for i in range(n_distinct)]
        k = minimum_bit_budget(xs)
        results.append((n_distinct, k, 2**k))

    n_vals = [r[0] for r in results]
    k_vals = [r[1] for r in results]
    bounds = [r[2] for r in results]

    ax.bar(n_vals, bounds, alpha=0.3, color='coral', label='2^k (capacity)')
    ax.plot(n_vals, n_vals, 'k--', linewidth=2, label='n_distinct (requirement)')
    ax.scatter(n_vals, n_vals, color='steelblue', s=30, zorder=5)

    ax.set_xlabel('Number of distinct values', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Distinct Values Bound: |dedup(xs)| ≤ 2^k',
                  fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_yscale('log', base=2)

    plt.tight_layout()
    return fig_to_base64(fig)


def viz_permutation_invariance():
    """Visualize permutation invariance of affine encodability."""
    fig, axes = plt.subplots(2, 3, figsize=(12, 6))
    import random
    random.seed(42)

    xs_orig = [Fraction(i) for i in [2, 5, 8, 11, 14]]
    k = minimum_bit_budget(xs_orig)
    enc_orig = compute_affine_encoding(xs_orig, k)

    perms = [xs_orig[:]]
    for _ in range(5):
        p = xs_orig[:]
        random.shuffle(p)
        perms.append(p)

    for idx, (ax, perm) in enumerate(zip(axes.flat, perms)):
        perm_float = [float(x) for x in perm]
        enc = compute_affine_encoding(perm, k)
        colors = ['steelblue'] * len(perm)

        ax.bar(range(len(perm)), perm_float, color=colors, alpha=0.7, edgecolor='navy')
        title = 'Original' if idx == 0 else f'Permutation {idx}'
        ax.set_title(f'{title}\nk={k}, quantized={enc.quantized}', fontsize=10)
        ax.set_ylim(0, 16)
        ax.set_xticks(range(len(perm)))
        ax.set_ylabel('Value' if idx % 3 == 0 else '')

    fig.suptitle('Permutation Invariance of Affine Encodability',
                  fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    b64_encoding = viz_affine_encoding()
    print(f"  viz_affine_encoding: {len(b64_encoding)} chars")

    b64_pipeline = viz_compression_pipeline()
    print(f"  viz_compression_pipeline: {len(b64_pipeline)} chars")

    b64_distinct = viz_distinct_values_bound()
    print(f"  viz_distinct_values_bound: {len(b64_distinct)} chars")

    b64_perm = viz_permutation_invariance()
    print(f"  viz_permutation_invariance: {len(b64_perm)} chars")

    print("All visualizations generated successfully!")
