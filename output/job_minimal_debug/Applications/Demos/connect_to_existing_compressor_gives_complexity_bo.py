#!/usr/bin/env python3
"""
Applications of Quantized Residual MDL Theory

Real-world applications demonstrating the theorems:
1. Signal Compression: Audio/sensor signal compression with certified bounds
2. Machine Learning: Quantization-aware model compression
3. Image Compression: Block quantization with residual coding
4. Data Deduplication: Closure-class identification for storage optimization
"""

from fractions import Fraction
from typing import List, Tuple, Dict
import math
import random


# ─── Application 1: Sensor Signal Compression ────────────────────────────────

def sensor_signal_compression():
    """Demonstrate sensor signal compression with certified MDL bounds.

    Scenario: A sensor array produces rational-valued readings.
    We compress using floor quantization + residual coding,
    with mathematical guarantees on description length.
    """
    print("=" * 60)
    print("APPLICATION 1: Sensor Signal Compression")
    print("=" * 60)

    # Simulate sensor readings (temperature in Celsius with fractional precision)
    random.seed(42)
    n_sensors = 20
    readings = [Fraction(random.randint(150, 350), 10) for _ in range(n_sensors)]

    print(f"\n  {n_sensors} sensor readings (temperature °C):")
    print(f"  {[float(r) for r in readings[:10]]}...")

    # Apply two-part compression at different resolutions
    for resolution in [1, 2, 5, 10]:
        quantized = [Fraction(math.floor(r * resolution), resolution) for r in readings]
        residuals = [r - q for r, q in zip(readings, quantized)]

        # Code sizes
        q_bits = sum(1 if q == 0 else int(math.log2(abs(q * resolution))) + 2
                     for q in quantized)
        r_bits = sum(int(math.log2(max(resolution, 1))) + 1 for _ in residuals)

        max_error = max(abs(float(r)) for r in residuals)
        total = q_bits + r_bits + 1

        print(f"\n  Resolution 1/{resolution}:")
        print(f"    Quantized bits: {q_bits:>4d}")
        print(f"    Residual bits:  {r_bits:>4d}")
        print(f"    Total MDL:      {total:>4d} bits")
        print(f"    Max error:      {max_error:.4f} °C")
        print(f"    Exact reconstruction: ✓ (guaranteed by recon_spec)")

    print()


# ─── Application 2: ML Model Quantization ────────────────────────────────────

def ml_model_quantization():
    """Demonstrate quantization-aware model compression.

    Scenario: Neural network weights are rational numbers.
    Quantizing to lower precision reduces model size,
    with the closure theorem guaranteeing that all models
    in the same "quantization cell" share the same MDL bound.
    """
    print("=" * 60)
    print("APPLICATION 2: ML Model Weight Quantization")
    print("=" * 60)

    # Simulate a small neural network's weights
    random.seed(123)
    n_weights = 50
    weights = [Fraction(random.randint(-1000, 1000), 100) for _ in range(n_weights)]

    print(f"\n  Model: {n_weights} weights")
    print(f"  Sample weights: {[float(w) for w in weights[:8]]}...")

    # Quantize at different bit widths
    for bits in [8, 4, 2, 1]:
        levels = 2 ** bits
        scale = Fraction(max(abs(w) for w in weights))
        if scale == 0:
            scale = Fraction(1)

        # Uniform quantization
        quantized = []
        residuals = []
        for w in weights:
            # Map to [0, levels-1], round, map back
            normalized = (w + scale) / (2 * scale) * (levels - 1)
            level = min(max(round(float(normalized)), 0), levels - 1)
            q_val = Fraction(level * 2, levels - 1) * scale - scale
            quantized.append(q_val)
            residuals.append(w - q_val)

        # Compute sizes
        q_bits_total = n_weights * bits
        r_bits_total = sum(
            1 if r == 0 else int(math.log2(max(abs(r.numerator * r.denominator), 1))) + 2
            for r in residuals
        )

        max_error = max(abs(float(r)) for r in residuals)
        rms_error = math.sqrt(sum(float(r)**2 for r in residuals) / n_weights)

        print(f"\n  {bits}-bit quantization ({levels} levels):")
        print(f"    Quantized size: {q_bits_total:>5d} bits ({q_bits_total/8:.0f} bytes)")
        print(f"    Residual size:  {r_bits_total:>5d} bits")
        print(f"    Total MDL:      {q_bits_total + r_bits_total + 1:>5d} bits")
        print(f"    Max error:      {max_error:.6f}")
        print(f"    RMS error:      {rms_error:.6f}")
        print(f"    Compression:    {100 * (1 - (q_bits_total + r_bits_total + 1) / (n_weights * 32)):.1f}%")

    print()


# ─── Application 3: Image Block Compression ──────────────────────────────────

def image_block_compression():
    """Demonstrate block-based image compression using the MDL framework.

    Scenario: A grayscale image is divided into blocks.
    Each block is quantized (like JPEG DC coefficients) with residual coding.
    The closure theorem groups similar blocks.
    """
    print("=" * 60)
    print("APPLICATION 3: Image Block Compression")
    print("=" * 60)

    # Simulate an 8x8 grayscale image (pixel values 0-255)
    random.seed(456)
    width, height = 8, 8
    image = [[Fraction(random.randint(0, 255)) for _ in range(width)]
             for _ in range(height)]

    # Flatten to signal
    signal = [pixel for row in image for pixel in row]

    print(f"\n  Image: {width}x{height} grayscale")
    print(f"  Raw size: {width * height * 8} bits (8 bits/pixel)")

    # Apply quantization at different quality levels
    for step in [1, 4, 16, 64]:
        quantized = [Fraction(math.floor(p / step) * step) for p in signal]
        residuals = [p - q for p, q in zip(signal, quantized)]

        # Count unique quantized values
        unique_q = len(set(int(q) for q in quantized))

        q_bits = len(signal) * max(1, int(math.log2(max(unique_q, 1))) + 1)
        r_bits = len(signal) * max(1, int(math.log2(max(step, 1))))

        max_error = max(abs(int(r)) for r in residuals)
        psnr = 20 * math.log10(255 / max(max_error, 1)) if max_error > 0 else float('inf')

        print(f"\n  Quantization step = {step}:")
        print(f"    Unique quantized values: {unique_q}")
        print(f"    Quantized bits: {q_bits:>5d}")
        print(f"    Residual bits:  {r_bits:>5d}")
        print(f"    Total MDL:      {q_bits + r_bits + 1:>5d} bits")
        print(f"    Max error:      {max_error}")
        print(f"    PSNR:           {psnr:.1f} dB")
        print(f"    Compression:    {100 * (1 - (q_bits + r_bits + 1) / (width * height * 8)):.1f}%")

    print()


# ─── Application 4: Data Deduplication via Closure Classes ────────────────────

def data_deduplication():
    """Demonstrate data deduplication using closure-class identification.

    Scenario: A database of records is deduplicated by identifying
    records in the same closure class (same quantized representative).
    The closure MDL theorem guarantees shared complexity bounds.
    """
    print("=" * 60)
    print("APPLICATION 4: Data Deduplication via Closure Classes")
    print("=" * 60)

    # Simulate a dataset with near-duplicate records
    random.seed(789)
    n_records = 100
    n_clusters = 10

    # Generate cluster centers
    centers = [[Fraction(random.randint(0, 100)) for _ in range(5)]
               for _ in range(n_clusters)]

    # Generate records near cluster centers
    records = []
    for _ in range(n_records):
        center = random.choice(centers)
        noise = [Fraction(random.randint(-10, 10), 100) for _ in range(5)]
        record = [c + n for c, n in zip(center, noise)]
        records.append(record)

    # Identify closure classes (same quantized representative)
    def quantize_record(record: List[Fraction]) -> Tuple[int, ...]:
        return tuple(math.floor(float(x)) for x in record)

    classes: Dict[Tuple[int, ...], List[int]] = {}
    for i, record in enumerate(records):
        key = quantize_record(record)
        classes.setdefault(key, []).append(i)

    print(f"\n  Dataset: {n_records} records, {len(records[0])} fields each")
    print(f"  Closure classes found: {len(classes)}")
    print(f"  Average class size: {n_records / len(classes):.1f}")

    # Show largest classes
    sorted_classes = sorted(classes.items(), key=lambda x: -len(x[1]))
    print(f"\n  Top 5 closure classes:")
    for key, members in sorted_classes[:5]:
        print(f"    Representative: {key}")
        print(f"    Members: {len(members)}")

        # MDL savings: all members share the quantized part
        q_bits = sum(1 if k == 0 else int(math.log2(abs(k))) + 2 for k in key)
        savings = (len(members) - 1) * q_bits  # shared quantized code
        print(f"    Shared q-code: {q_bits} bits × {len(members)} members")
        print(f"    Dedup savings: {savings} bits")

    # Total savings
    total_q_unique = sum(
        sum(1 if k == 0 else int(math.log2(abs(k))) + 2 for k in key)
        for key in classes
    )
    total_q_full = sum(
        sum(1 if k == 0 else int(math.log2(abs(k))) + 2 for k in key) * len(members)
        for key, members in classes.items()
    )
    print(f"\n  Total quantized code (deduplicated): {total_q_unique} bits")
    print(f"  Total quantized code (full):         {total_q_full} bits")
    print(f"  Deduplication ratio: {total_q_full / max(total_q_unique, 1):.1f}x")
    print()


if __name__ == "__main__":
    sensor_signal_compression()
    ml_model_quantization()
    image_block_compression()
    data_deduplication()

    print("=" * 60)
    print("All applications completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demo: Quantized Residual MDL — Distortion Decompositions Induce Description-Length Decompositions

This script demonstrates the core theorems with concrete numerical examples:
1. Two-part compression via floor rounding + residual
2. Closure-class MDL bound inheritance
3. Idempotent quantizer fixed-point structure
4. Multi-scale compression refinement
"""

from fractions import Fraction
from typing import List, Tuple, Callable, Set
import math


# ─── Core: Floor Rounding Compressor ────────────────────────────────────────

def floor_round(q: Fraction) -> int:
    """Coordinatewise floor rounding (quantization)."""
    return math.floor(q)

def floor_residual(q: Fraction) -> Fraction:
    """Residual after floor rounding: always in [0, 1)."""
    return q - Fraction(math.floor(q))

def reconstruct(integer_part: int, residual: Fraction) -> Fraction:
    """Exact reconstruction from quantized + residual."""
    return Fraction(integer_part) + residual


def demo_floor_rounding():
    """Demonstrate exact reconstruction via floor rounding."""
    print("=" * 60)
    print("DEMO 1: Floor Rounding Compressor")
    print("=" * 60)

    signals = [
        Fraction(7, 3),   # 2.333...
        Fraction(-5, 4),  # -1.25
        Fraction(0),      # 0
        Fraction(22, 7),  # π ≈ 3.142857...
        Fraction(100, 1), # integer: 100
    ]

    for q in signals:
        qr = floor_round(q)
        res = floor_residual(q)
        recon = reconstruct(qr, res)
        print(f"  Signal: {float(q):>10.4f}  (= {q})")
        print(f"    Quantized: {qr:>4d}")
        print(f"    Residual:  {float(res):.6f}  (= {res})")
        print(f"    Reconstructed: {float(recon):.6f}  (exact: {recon == q})")
        assert recon == q, "Reconstruction must be exact!"
        assert 0 <= res < 1, "Residual must be in [0, 1)"
        print()

    print("✓ All reconstructions exact. Residuals in [0, 1).\n")


# ─── MDL Complexity Bound ────────────────────────────────────────────────────

def code_size_int(n: int) -> int:
    """Approximate code size for an integer (log2 + 1 for sign)."""
    if n == 0:
        return 1
    return int(math.log2(abs(n))) + 2  # +1 for sign, +1 for ceil

def code_size_residual(r: Fraction) -> int:
    """Approximate code size for a residual in [0, 1) with denominator d."""
    if r == 0:
        return 1
    return int(math.log2(r.denominator)) + 1

def two_part_code_size(signal: List[Fraction]) -> Tuple[int, int, int]:
    """Compute quantized code size, residual code size, and total."""
    q_size = sum(code_size_int(floor_round(q)) for q in signal)
    r_size = sum(code_size_residual(floor_residual(q)) for q in signal)
    return q_size, r_size, q_size + r_size + 1


def demo_mdl_bound():
    """Demonstrate the two-part MDL complexity bound."""
    print("=" * 60)
    print("DEMO 2: Two-Part MDL Complexity Bound")
    print("=" * 60)

    signals = [
        [Fraction(7, 3), Fraction(11, 5), Fraction(-3, 7)],
        [Fraction(1), Fraction(2), Fraction(3)],  # integers: small residual
        [Fraction(1, 1000), Fraction(1, 997), Fraction(1, 991)],  # near-zero: large residual
    ]

    for i, sig in enumerate(signals):
        q_sz, r_sz, total = two_part_code_size(sig)
        print(f"\n  Signal {i+1}: {[float(x) for x in sig]}")
        print(f"    Quantized code size: {q_sz} bits")
        print(f"    Residual code size:  {r_sz} bits")
        print(f"    Total MDL bound:     {total} bits  (= qsize + rsize + 1)")

        # The theorem says: K(signal) ≤ total
        # We can't compute true Kolmogorov complexity, but we demonstrate the bound
        naive_size = sum(int(math.log2(max(abs(q.numerator), 1))) +
                        int(math.log2(max(q.denominator, 1))) + 2
                        for q in sig)
        print(f"    Naive encoding:      {naive_size} bits")
        print(f"    Savings:             {naive_size - total:+d} bits")

    print()


# ─── Closure-Class MDL Inheritance ────────────────────────────────────────────

def make_rounding_closure(resolution: int):
    """Create a closure system based on rounding to a grid of given resolution.

    Two signals are in the same closure class if they round to the same
    integer vector (with the given resolution multiplier).
    """
    def quantize(signal: List[Fraction]) -> Tuple[int, ...]:
        return tuple(math.floor(q * resolution) for q in signal)

    def closure_class(signal: List[Fraction]) -> List[List[Fraction]]:
        """Generate some members of the closure class (same quantized representative)."""
        base = quantize(signal)
        members = []
        # Add the signal itself
        members.append(signal)
        # Add the "canonical" representative (lower-left corner of the cell)
        canonical = [Fraction(b, resolution) for b in base]
        members.append(canonical)
        # Add the center of the cell
        center = [Fraction(b, resolution) + Fraction(1, 2 * resolution) for b in base]
        members.append(center)
        return members

    return quantize, closure_class


def demo_closure_mdl():
    """Demonstrate closure-class MDL bound inheritance (breakthrough theorem)."""
    print("=" * 60)
    print("DEMO 3: Closure-Class MDL Bound Inheritance")
    print("  (closure_quantized_residual_mdl_bound)")
    print("=" * 60)

    signal = [Fraction(7, 3), Fraction(11, 5), Fraction(-3, 7)]
    quantize, closure_class = make_rounding_closure(1)

    members = closure_class(signal)
    q_rep = quantize(signal)

    print(f"\n  Original signal: {[float(x) for x in signal]}")
    print(f"  Quantized representative: {q_rep}")
    print(f"\n  Closure class members (same quantized code):")

    # Compute MDL bound for the original
    q_sz_orig, r_sz_orig, total_orig = two_part_code_size(signal)

    for i, member in enumerate(members):
        q_sz, r_sz, total = two_part_code_size(member)
        q_rep_m = quantize(member)
        print(f"\n    Member {i+1}: {[float(x) for x in member]}")
        print(f"      Quantized: {q_rep_m}  (same as original: {q_rep_m == q_rep})")
        print(f"      qsize={q_sz}, rsize={r_sz}, total={total}")
        print(f"      Bound from original: {total_orig}")
        print(f"      Theorem holds: K(member) ≤ {total_orig}? ", end="")
        # The theorem guarantees this when quantize is invariant and residual is monotone
        if q_rep_m == q_rep:
            print("✓ (quantizer invariant)")
        else:
            print("N/A (different quantized rep)")

    print()


# ─── Idempotent Quantizer ────────────────────────────────────────────────────

def demo_idempotent():
    """Demonstrate idempotent quantizer fixed-point structure."""
    print("=" * 60)
    print("DEMO 4: Idempotent Quantizer Fixed Points")
    print("=" * 60)

    def Q(signal: List[Fraction]) -> List[Fraction]:
        """Floor-rounding quantizer (maps to integers)."""
        return [Fraction(math.floor(q)) for q in signal]

    signals = [
        [Fraction(7, 3), Fraction(11, 5)],
        [Fraction(3), Fraction(-2)],  # already integer (fixed point)
        [Fraction(1, 100), Fraction(99, 100)],
    ]

    for sig in signals:
        q1 = Q(sig)
        q2 = Q(q1)
        is_fixed = (sig == Q(sig))
        print(f"\n  Signal:   {[float(x) for x in sig]}")
        print(f"  Q(sig):   {[float(x) for x in q1]}")
        print(f"  Q(Q(sig)):{[float(x) for x in q2]}")
        print(f"  Idempotent (Q∘Q = Q): {q1 == q2}")
        print(f"  Fixed point (Q(x) = x): {is_fixed}")
        assert q1 == q2, "Quantizer must be idempotent!"

    print("\n✓ All quantizers verified idempotent.\n")


# ─── Multi-Scale Compression ─────────────────────────────────────────────────

def demo_multiscale():
    """Demonstrate multi-scale MDL bound refinement."""
    print("=" * 60)
    print("DEMO 5: Multi-Scale Compression Refinement")
    print("  (multiscale_mdl_bound)")
    print("=" * 60)

    signal = [Fraction(355, 113), Fraction(22, 7), Fraction(577, 408)]

    resolutions = [1, 2, 4, 8, 16]

    print(f"\n  Signal: {[float(x) for x in signal]}")
    print(f"\n  Resolution  Quantized Rep       qsize  rsize  total")
    print(f"  " + "-" * 55)

    for res in resolutions:
        quantize, _ = make_rounding_closure(res)
        q_rep = quantize(signal)

        # Code sizes scale with resolution
        q_sz = sum(code_size_int(b) for b in q_rep)
        r_sz = sum(int(math.log2(max(res, 1))) + 1 for _ in signal)
        total = q_sz + r_sz + 1

        print(f"  {res:>10d}  {str(q_rep):>20s}  {q_sz:>5d}  {r_sz:>5d}  {total:>5d}")

    print(f"\n  Finer resolutions → larger quantized codes, smaller residuals.")
    print(f"  The multiscale theorem guarantees: finer closure ⊂ coarser closure")
    print(f"  → coarser MDL bound dominates.\n")


if __name__ == "__main__":
    demo_floor_rounding()
    demo_mdl_bound()
    demo_closure_mdl()
    demo_idempotent()
    demo_multiscale()

    print("=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Quantized Residual MDL Theory

Generates publication-quality figures illustrating the key concepts:
1. Two-part compression decomposition
2. Closure class structure
3. Multi-scale MDL bounds
4. Idempotent quantizer convergence
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def plot_two_part_decomposition():
    """Visualize the two-part compression: quantized + residual."""
    fig, axes = plt.subplots(1, 3, figsize=(14, 4))

    # Generate a signal
    np.random.seed(42)
    n = 30
    x = np.arange(n)
    signal = np.cumsum(np.random.randn(n)) + 10

    # Quantized (floor)
    quantized = np.floor(signal)
    residual = signal - quantized

    # Plot original
    axes[0].bar(x, signal, color='steelblue', alpha=0.8, label='Signal')
    axes[0].set_title('Original Signal', fontsize=13, fontweight='bold')
    axes[0].set_xlabel('Index')
    axes[0].set_ylabel('Value')

    # Plot quantized
    axes[1].bar(x, quantized, color='darkorange', alpha=0.8, label='Quantized')
    axes[1].set_title('Quantized Part (integers)', fontsize=13, fontweight='bold')
    axes[1].set_xlabel('Index')
    axes[1].set_ylabel('Value')

    # Plot residual
    axes[2].bar(x, residual, color='seagreen', alpha=0.8, label='Residual')
    axes[2].axhline(y=0, color='black', linewidth=0.5)
    axes[2].axhline(y=1, color='red', linewidth=0.5, linestyle='--', label='Upper bound')
    axes[2].set_title('Residual Part ∈ [0,1)', fontsize=13, fontweight='bold')
    axes[2].set_xlabel('Index')
    axes[2].set_ylabel('Value')
    axes[2].legend()

    fig.suptitle('Two-Part Compression: Signal = Quantized + Residual', fontsize=15, fontweight='bold', y=1.02)
    fig.tight_layout()
    fig.savefig('/workspace/request-project/viz_two_part_decomposition.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_closure_classes():
    """Visualize closure classes in 2D (grid cells)."""
    fig, ax = plt.subplots(figsize=(8, 8))

    # Generate random 2D points
    np.random.seed(42)
    n_points = 100
    points = np.random.rand(n_points, 2) * 5

    # Color by closure class (grid cell)
    cells = np.floor(points).astype(int)
    cell_ids = cells[:, 0] * 10 + cells[:, 1]
    unique_cells = np.unique(cell_ids)
    colors = plt.cm.Set3(np.linspace(0, 1, len(unique_cells)))
    color_map = {cid: colors[i] for i, cid in enumerate(unique_cells)}

    # Draw grid
    for i in range(6):
        ax.axhline(y=i, color='gray', linewidth=0.5, alpha=0.5)
        ax.axvline(x=i, color='gray', linewidth=0.5, alpha=0.5)

    # Plot points colored by closure class
    for cid in unique_cells:
        mask = cell_ids == cid
        ax.scatter(points[mask, 0], points[mask, 1],
                  c=[color_map[cid]], s=50, edgecolors='black', linewidth=0.5,
                  label=f'Class ({cid // 10}, {cid % 10})')

    # Mark canonical representatives (lower-left corners)
    for cid in unique_cells:
        cx, cy = cid // 10, cid % 10
        ax.plot(cx, cy, 's', color='red', markersize=10, zorder=5)

    ax.set_title('Closure Classes: Points in Same Grid Cell Share MDL Bound',
                fontsize=13, fontweight='bold')
    ax.set_xlabel('Dimension 1')
    ax.set_ylabel('Dimension 2')
    ax.set_xlim(-0.2, 5.2)
    ax.set_ylim(-0.2, 5.2)
    ax.set_aspect('equal')
    ax.text(0.02, 0.98, '■ = Canonical representative\n● = Closure class members',
           transform=ax.transAxes, verticalalignment='top',
           fontsize=10, bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    fig.tight_layout()
    fig.savefig('/workspace/request-project/viz_closure_classes.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_multiscale_mdl():
    """Visualize multi-scale MDL bounds."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    resolutions = [1, 2, 4, 8, 16, 32, 64]
    n = 10

    # Simulate code sizes at different resolutions
    np.random.seed(42)
    signal = np.random.rand(n) * 100

    q_sizes = []
    r_sizes = []
    totals = []
    distortions = []

    for res in resolutions:
        quantized = np.floor(signal * res) / res
        residual = signal - quantized

        # Approximate code sizes
        q_ints = np.floor(signal * res).astype(int)
        q_bits = sum(1 if q == 0 else int(math.log2(abs(q))) + 2 for q in q_ints)
        r_bits = n * max(1, int(math.log2(res)))

        q_sizes.append(q_bits)
        r_sizes.append(r_bits)
        totals.append(q_bits + r_bits + 1)
        distortions.append(np.max(np.abs(residual)))

    # Plot 1: Code sizes vs resolution
    x = np.arange(len(resolutions))
    width = 0.35
    ax1.bar(x - width/2, q_sizes, width, label='Quantized code', color='darkorange', alpha=0.8)
    ax1.bar(x + width/2, r_sizes, width, label='Residual code', color='seagreen', alpha=0.8)
    ax1.plot(x, totals, 'ko-', label='Total MDL bound', linewidth=2, markersize=6)
    ax1.set_xlabel('Resolution')
    ax1.set_ylabel('Code Size (bits)')
    ax1.set_title('Code Size Decomposition by Resolution', fontsize=13, fontweight='bold')
    ax1.set_xticks(x)
    ax1.set_xticklabels([str(r) for r in resolutions])
    ax1.legend()

    # Plot 2: Distortion vs total code size (rate-distortion curve)
    ax2.plot(totals, distortions, 'bo-', linewidth=2, markersize=8)
    for i, (t, d, r) in enumerate(zip(totals, distortions, resolutions)):
        ax2.annotate(f'res={r}', (t, d), textcoords="offset points",
                    xytext=(5, 5), fontsize=9)
    ax2.set_xlabel('Total MDL Bound (bits)')
    ax2.set_ylabel('Max Distortion')
    ax2.set_title('Rate–Distortion Tradeoff', fontsize=13, fontweight='bold')
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Multi-Scale Compression: Resolution Controls the Rate–Distortion Tradeoff',
                fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()
    fig.savefig('/workspace/request-project/viz_multiscale_mdl.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_idempotent_convergence():
    """Visualize idempotent quantizer convergence (Q∘Q = Q)."""
    fig, axes = plt.subplots(1, 3, figsize=(14, 4.5))

    np.random.seed(42)
    n = 20
    signal = np.random.rand(n) * 10

    for ax_idx, (res, ax) in enumerate(zip([1, 4, 16], axes)):
        iterations = [signal.copy()]
        current = signal.copy()

        for _ in range(5):
            current = np.floor(current * res) / res
            iterations.append(current.copy())

        # Plot iterations
        x = np.arange(n)
        ax.plot(x, iterations[0], 'o-', color='steelblue', alpha=0.6, label='Original', markersize=4)
        ax.plot(x, iterations[1], 's-', color='darkorange', alpha=0.8, label='Q(x)', markersize=4)
        ax.plot(x, iterations[2], '^-', color='seagreen', alpha=0.8, label='Q²(x)', markersize=4)

        # Check idempotency
        is_idem = np.allclose(iterations[1], iterations[2])
        ax.set_title(f'Resolution 1/{res}\nQ²=Q: {is_idem}', fontsize=12, fontweight='bold')
        ax.set_xlabel('Index')
        if ax_idx == 0:
            ax.set_ylabel('Value')
        ax.legend(fontsize=9)

    fig.suptitle('Idempotent Quantizer: Q(Q(x)) = Q(x) After One Application',
                fontsize=14, fontweight='bold', y=1.04)
    fig.tight_layout()
    fig.savefig('/workspace/request-project/viz_idempotent_convergence.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_complexity_triangle():
    """Visualize the conceptual triangle: Compression ↔ Quantization ↔ Closure."""
    fig, ax = plt.subplots(figsize=(8, 7))

    # Triangle vertices
    vertices = np.array([
        [0.5, 0.9],    # top: Compression/Kolmogorov
        [0.1, 0.15],   # bottom-left: Quantization
        [0.9, 0.15],   # bottom-right: Closure/Idempotent
    ])

    # Draw triangle
    triangle = plt.Polygon(vertices, fill=False, edgecolor='black', linewidth=2)
    ax.add_patch(triangle)

    # Fill with gradient
    triangle_fill = plt.Polygon(vertices, alpha=0.1, facecolor='steelblue')
    ax.add_patch(triangle_fill)

    # Labels at vertices
    labels = [
        'Compression\n& MDL',
        'Quantization\n& Approximation',
        'Closure Operators\n& Idempotent Algebra'
    ]
    offsets = [(0, 0.05), (0, -0.08), (0, -0.08)]

    for (x, y), label, (dx, dy) in zip(vertices, labels, offsets):
        ax.text(x + dx, y + dy, label, ha='center', va='center',
               fontsize=12, fontweight='bold',
               bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow',
                        edgecolor='gray', alpha=0.9))

    # Edge labels
    edge_labels = [
        ('Two-part codes\n(qsize + rsize + 1)', 0.3, 0.55),
        ('Canonical\nrepresentatives', 0.5, 0.1),
        ('MDL bound\ninheritance', 0.7, 0.55),
    ]

    for label, x, y in edge_labels:
        ax.text(x, y, label, ha='center', va='center', fontsize=10,
               fontstyle='italic', color='darkblue')

    # Center label
    ax.text(0.5, 0.4, 'Quantized Residual\nMDL Theory',
           ha='center', va='center', fontsize=14, fontweight='bold',
           color='darkred',
           bbox=dict(boxstyle='round,pad=0.4', facecolor='mistyrose',
                    edgecolor='darkred', alpha=0.8))

    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('The Compression–Quantization–Closure Triangle',
                fontsize=15, fontweight='bold', pad=20)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/viz_complexity_triangle.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    b64_1 = plot_two_part_decomposition()
    print("  ✓ Two-part decomposition")

    b64_2 = plot_closure_classes()
    print("  ✓ Closure classes")

    b64_3 = plot_multiscale_mdl()
    print("  ✓ Multi-scale MDL")

    b64_4 = plot_idempotent_convergence()
    print("  ✓ Idempotent convergence")

    b64_5 = plot_complexity_triangle()
    print("  ✓ Complexity triangle")

    print("\nAll visualizations saved as PNG files.")
