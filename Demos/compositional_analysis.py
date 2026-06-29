#!/usr/bin/env python3
"""
Real-World Applications of Compositional Tropical Event-Graph Semantics

Demonstrates how the formal compositional framework applies to:
1. Hardware pipeline timing analysis
2. Railway timetable composition
3. Streaming DSP graph scheduling
4. Manufacturing assembly line optimization
"""

import numpy as np
from algorithms import (
    trop_matmul, trop_matpow, max_cycle_mean, MaxPlusMatrix,
    Network, evaluate_network, certify_throughput, verify_certification,
    NEG_INF
)


def app_hardware_pipeline():
    """
    Application 1: VLSI Hardware Pipeline Timing Analysis

    Models a 4-stage processor pipeline:
      Fetch → Decode → Execute → Writeback

    Each stage has multiple functional units with different latencies.
    Series composition gives end-to-end worst-case latency.
    """
    print("=" * 70)
    print("APPLICATION 1: Hardware Pipeline Timing (4-stage processor)")
    print("=" * 70)

    # Stage 1: Fetch (2 fetch units → 2 decode inputs)
    fetch = np.array([[3, 2],   # Fetch unit 1: 3ns to decode port 1, 2ns to port 2
                      [1, 4]])  # Fetch unit 2: 1ns to decode port 1, 4ns to port 2

    # Stage 2: Decode (2 → 3 execution units)
    decode = np.array([[2, 5, 1],
                       [3, 2, 4]])

    # Stage 3: Execute (3 → 2 writeback ports)
    execute = np.array([[4, 3],
                        [2, 6],
                        [5, 1]])

    # Stage 4: Writeback (2 → 1 commit)
    writeback = np.array([[2],
                          [3]])

    # Compose all stages
    fd = trop_matmul(fetch, decode)
    fde = trop_matmul(fd, execute)
    full = trop_matmul(fde, writeback)

    print("Stage latencies (ns):")
    print(f"  Fetch:     {fetch.tolist()}")
    print(f"  Decode:    {decode.tolist()}")
    print(f"  Execute:   {execute.tolist()}")
    print(f"  Writeback: {writeback.tolist()}")
    print(f"\nEnd-to-end latency (Fetch→Commit):\n{full}")
    print(f"Critical path delay: {np.max(full):.0f} ns")

    # Compositional certification
    bounds = [np.max(s) for s in [fetch, decode, execute, writeback]]
    certified = sum(bounds)
    actual = np.max(full)
    print(f"\nPer-stage bounds: {bounds}")
    print(f"Certified total bound (sum): {certified}")
    print(f"Actual max: {actual}")
    print(f"✓ Sound: {actual <= certified}")
    print()


def app_railway_timetable():
    """
    Application 2: Railway Timetable Composition

    Models delay propagation through a railway network:
      Station A → Junction B → Station C
                              → Station D

    The max-plus framework naturally handles:
    - Connection times at junctions
    - Worst-case delay propagation
    - Modular timetable verification
    """
    print("=" * 70)
    print("APPLICATION 2: Railway Timetable Composition")
    print("=" * 70)

    # Segment A→B: 2 platforms at A, 3 tracks at junction B
    # Entry (i,j) = minimum travel time from platform i to track j
    seg_AB = np.array([[12, 15, NEG_INF],   # Platform 1 can reach tracks 1,2
                       [14, 11, 18]])        # Platform 2 can reach all tracks

    # Segment B→C: 3 tracks at B, 2 platforms at C
    seg_BC = np.array([[8, 10],
                       [NEG_INF, 7],
                       [9, 12]])

    # Segment B→D: 3 tracks at B, 1 platform at D
    seg_BD = np.array([[6],
                       [8],
                       [5]])

    # End-to-end: A→C and A→D
    seg_AC = trop_matmul(seg_AB, seg_BC)
    seg_AD = trop_matmul(seg_AB, seg_BD)

    print("Segment A→B (travel times):")
    print(f"  {seg_AB}")
    print("Segment B→C:")
    print(f"  {seg_BC}")
    print("Segment B→D:")
    print(f"  {seg_BD}")
    print(f"\nEnd-to-end A→C:\n  {seg_AC}")
    print(f"End-to-end A→D:\n  {seg_AD}")
    print(f"\nWorst-case A→C: {np.max(seg_AC[seg_AC > NEG_INF]):.0f} min")
    print(f"Worst-case A→D: {np.max(seg_AD[seg_AD > NEG_INF]):.0f} min")

    # Compositional bound
    bound_AB = np.max(seg_AB[seg_AB > NEG_INF])
    bound_BC = np.max(seg_BC[seg_BC > NEG_INF])
    print(f"\nCompositional bound A→C: {bound_AB} + {bound_BC} = {bound_AB + bound_BC}")
    print(f"Actual max A→C: {np.max(seg_AC[seg_AC > NEG_INF]):.0f}")
    print()


def app_streaming_dsp():
    """
    Application 3: Streaming DSP Graph Scheduling

    Models a signal processing pipeline:
      Source → [FFT ∥ Filter] → Combine → Sink

    Parallel paths represent concurrent processing stages.
    The critical path determines the system throughput.
    """
    print("=" * 70)
    print("APPLICATION 3: Streaming DSP Graph")
    print("=" * 70)

    # Source: 1 input → 2 outputs (to FFT and Filter)
    source = np.array([[5, 3]])  # Latencies to FFT input and Filter input

    # FFT path: 2→2 internal
    fft = np.array([[8, 4],
                    [3, 10]])

    # Filter path: 2→2 internal
    filt = np.array([[6, 7],
                     [2, 5]])

    # Parallel composition (shared interface)
    parallel_stage = np.maximum(fft, filt)

    # Combiner: 2 inputs → 1 output
    combine = np.array([[4],
                        [6]])

    # Full pipeline
    full = trop_matmul(trop_matmul(source, parallel_stage), combine)

    print("Source transfer: ", source.tolist())
    print("FFT transfer:    ", fft.tolist())
    print("Filter transfer: ", filt.tolist())
    print(f"Parallel (max):  {parallel_stage.tolist()}")
    print("Combiner:        ", combine.tolist())
    print(f"\nEnd-to-end latency: {full}")
    print(f"System throughput bound: 1/{np.max(full):.0f} samples/cycle")
    print()


def app_manufacturing():
    """
    Application 4: Manufacturing Assembly Line

    Models a multi-product assembly system with shared workstations.
    Each product takes a different path through the factory.
    Max-plus analysis reveals bottlenecks and cycle times.
    """
    print("=" * 70)
    print("APPLICATION 4: Manufacturing Assembly Line")
    print("=" * 70)

    # Workstation transfer matrices (processing + transport times)
    # Station 1: Raw materials → Machining (2 machines)
    ws1 = np.array([[10, 8],
                    [7, 12]])

    # Station 2: Machining → Assembly (2 machines → 2 assembly lines)
    ws2 = np.array([[5, 9],
                    [11, 4]])

    # Station 3: Assembly → Quality check (2 lines → 1 output)
    ws3 = np.array([[6],
                    [8]])

    # Full pipeline
    full = trop_matmul(trop_matmul(ws1, ws2), ws3)

    print("Station 1 (Raw→Machine):")
    print(f"  {ws1}")
    print("Station 2 (Machine→Assembly):")
    print(f"  {ws2}")
    print("Station 3 (Assembly→QC):")
    print(f"  {ws3}")
    print(f"\nEnd-to-end (Raw→QC): {full.T}")

    # Cyclic analysis: if the system loops back
    cyclic = trop_matmul(trop_matmul(ws1, ws2), ws2.T)  # Simplified feedback
    mcm = max_cycle_mean(cyclic)
    print(f"\nFeedback cycle mean: {mcm:.2f}")
    print(f"Minimum cycle time: {mcm:.2f} time units")
    print(f"Maximum throughput: {1/mcm:.4f} products/time unit" if mcm > 0 else "")

    # Compositional analysis
    net = Network.series(
        Network.series(Network.atom(ws1), Network.atom(ws2)),
        Network.atom(ws3)
    )
    actual, certified, sound = verify_certification(net)
    print(f"\nCompositional certification:")
    print(f"  Actual max delay: {actual}")
    print(f"  Certified bound:  {certified}")
    print(f"  ✓ Sound: {sound}")
    print()


if __name__ == "__main__":
    app_hardware_pipeline()
    app_railway_timetable()
    app_streaming_dsp()
    app_manufacturing()
    print("All applications demonstrated successfully!")


#!/usr/bin/env python3
"""
Compositional Tropical Semantics for Event Graphs — Demonstrations

This module demonstrates the core theorems of compositional tropical
event-graph semantics with concrete numerical examples:

1. Series composition = max-plus matrix multiplication
2. Parallel composition (shared) = pointwise max
3. Parallel composition (disjoint) = block diagonal
4. Compositional throughput certification
"""

import numpy as np
from typing import Tuple


def trop_max_plus(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Max-plus (tropical) matrix multiplication.
    (A ⊗ B)_{i,k} = max_j (A_{i,j} + B_{j,k})

    This replaces standard matrix multiplication where:
    - addition becomes max
    - multiplication becomes addition
    """
    m, n = A.shape
    _, p = B.shape
    C = np.full((m, p), -np.inf)
    for i in range(m):
        for k in range(p):
            for j in range(n):
                C[i, k] = max(C[i, k], A[i, j] + B[j, k])
    return C


def trop_pointwise_max(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Pointwise maximum (tropical addition of matrices)."""
    return np.maximum(A, B)


def trop_block_diag(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical block-diagonal assembly."""
    m1, n1 = A.shape
    m2, n2 = B.shape
    C = np.zeros((m1 + m2, n1 + n2))
    C[:m1, :n1] = A
    C[m1:, n1:] = B
    return C


def demo_series_composition():
    """
    Demo 1: Two-stage pipeline
    Stage 1: delay matrix [[3]]
    Stage 2: delay matrix [[5]]
    Series result: [[3+5]] = [[8]] (tropical multiplication = addition)
    """
    print("=" * 60)
    print("DEMO 1: Series Composition (2-stage pipeline)")
    print("=" * 60)

    G1 = np.array([[3.0]])
    G2 = np.array([[5.0]])
    result = trop_max_plus(G1, G2)

    print(f"Stage 1 transfer: {G1}")
    print(f"Stage 2 transfer: {G2}")
    print(f"Series (tropical product): {result}")
    print(f"Expected: [[8.0]]  (3 + 5 = 8)")
    print(f"✓ Verified: {np.allclose(result, [[8.0]])}")
    print()


def demo_series_2x2():
    """
    Demo 2: 2×2 multi-port pipeline
    Stage 1: [[1, 3], [2, 4]]
    Stage 2: [[5, 6], [7, 8]]
    Result_{i,k} = max_j (G1_{i,j} + G2_{j,k})
    """
    print("=" * 60)
    print("DEMO 2: Series Composition (2×2 pipeline)")
    print("=" * 60)

    G1 = np.array([[1, 3], [2, 4]])
    G2 = np.array([[5, 6], [7, 8]])
    result = trop_max_plus(G1, G2)

    print(f"Stage 1:\n{G1}")
    print(f"Stage 2:\n{G2}")
    print(f"Series (max-plus product):\n{result}")

    # Manual verification:
    # (0,0): max(1+5, 3+7) = max(6,10) = 10
    # (0,1): max(1+6, 3+8) = max(7,11) = 11
    # (1,0): max(2+5, 4+7) = max(7,11) = 11
    # (1,1): max(2+6, 4+8) = max(8,12) = 12
    expected = np.array([[10, 11], [11, 12]])
    print(f"Expected:\n{expected}")
    print(f"✓ Verified: {np.allclose(result, expected)}")
    print()


def demo_parallel_shared():
    """
    Demo 3: Fork-join with shared interfaces
    Path A: delay 3
    Path B: delay 5
    Result: max(3, 5) = 5 (critical path)
    """
    print("=" * 60)
    print("DEMO 3: Shared Parallel Composition (fork-join)")
    print("=" * 60)

    G1 = np.array([[3.0]])
    G2 = np.array([[5.0]])
    result = trop_pointwise_max(G1, G2)

    print(f"Path A transfer: {G1}")
    print(f"Path B transfer: {G2}")
    print(f"Parallel (pointwise max): {result}")
    print(f"Expected: [[5.0]]  (max(3, 5) = 5)")
    print(f"✓ Verified: {np.allclose(result, [[5.0]])}")
    print()


def demo_parallel_disjoint():
    """
    Demo 4: Disjoint parallel composition (independent subsystems)
    System A: 2×2 matrix
    System B: 1×1 matrix
    Result: 3×3 block diagonal
    """
    print("=" * 60)
    print("DEMO 4: Disjoint Parallel Composition")
    print("=" * 60)

    G1 = np.array([[1, 2], [3, 4]])
    G2 = np.array([[10.0]])
    result = trop_block_diag(G1, G2)

    print(f"System A:\n{G1}")
    print(f"System B:\n{G2}")
    print(f"Block diagonal:\n{result}")

    expected = np.array([[1, 2, 0], [3, 4, 0], [0, 0, 10]])
    print(f"Expected:\n{expected}")
    print(f"✓ Verified: {np.allclose(result, expected)}")
    print()


def demo_throughput_certification():
    """
    Demo 5: Compositional throughput certification
    Shows that cycle-time bounds compose:
    - Series: c₁ + c₂
    - Parallel (shared): max(c₁, c₂)
    """
    print("=" * 60)
    print("DEMO 5: Compositional Throughput Certification")
    print("=" * 60)

    # Three-stage pipeline
    G1 = np.array([[2, 1], [3, 2]])  # bound: 3
    G2 = np.array([[4, 3], [1, 5]])  # bound: 5
    G3 = np.array([[1, 2], [3, 1]])  # bound: 3

    c1 = np.max(G1)
    c2 = np.max(G2)
    c3 = np.max(G3)

    print(f"Stage 1 (bound={c1}):\n{G1}")
    print(f"Stage 2 (bound={c2}):\n{G2}")
    print(f"Stage 3 (bound={c3}):\n{G3}")

    # Series: G1 then G2 then G3
    series_12 = trop_max_plus(G1, G2)
    series_123 = trop_max_plus(series_12, G3)
    actual_bound_series = np.max(series_123)
    certified_bound_series = c1 + c2 + c3

    print(f"\nSeries G1→G2→G3:\n{series_123}")
    print(f"Actual max entry: {actual_bound_series}")
    print(f"Certified bound (c1+c2+c3): {certified_bound_series}")
    print(f"✓ Bound holds: {actual_bound_series <= certified_bound_series}")

    # Parallel (shared): G1 ∥ G2
    par_12 = trop_pointwise_max(G1, G2)
    actual_bound_par = np.max(par_12)
    certified_bound_par = max(c1, c2)

    print(f"\nParallel G1∥G2:\n{par_12}")
    print(f"Actual max entry: {actual_bound_par}")
    print(f"Certified bound max(c1,c2): {certified_bound_par}")
    print(f"✓ Bound holds: {actual_bound_par <= certified_bound_par}")
    print()


def demo_associativity():
    """
    Demo 6: Associativity of series composition
    Shows (G1 ⊗ G2) ⊗ G3 = G1 ⊗ (G2 ⊗ G3)
    """
    print("=" * 60)
    print("DEMO 6: Associativity of Series Composition")
    print("=" * 60)

    np.random.seed(42)
    G1 = np.random.randint(0, 10, (3, 4)).astype(float)
    G2 = np.random.randint(0, 10, (4, 2)).astype(float)
    G3 = np.random.randint(0, 10, (2, 5)).astype(float)

    left = trop_max_plus(trop_max_plus(G1, G2), G3)
    right = trop_max_plus(G1, trop_max_plus(G2, G3))

    print(f"G1 ({G1.shape}):\n{G1}")
    print(f"G2 ({G2.shape}):\n{G2}")
    print(f"G3 ({G3.shape}):\n{G3}")
    print(f"\n(G1⊗G2)⊗G3:\n{left}")
    print(f"G1⊗(G2⊗G3):\n{right}")
    print(f"✓ Associative: {np.allclose(left, right)}")
    print()


def demo_railway_scheduling():
    """
    Demo 7: Railway segment composition
    Models delay propagation through a 3-station railway network.

    Station A→B: two tracks with delays [4,6] and [5,3]
    Station B→C: two tracks with delays [2,7] and [8,1]

    The max-plus product gives the worst-case propagation delay
    from each track at A to each track at C.
    """
    print("=" * 60)
    print("DEMO 7: Railway Scheduling Application")
    print("=" * 60)

    # Segment A→B transfer matrix (2 tracks)
    seg_AB = np.array([[4, 6], [5, 3]])
    # Segment B→C transfer matrix (2 tracks)
    seg_BC = np.array([[2, 7], [8, 1]])

    # End-to-end delay: A→C
    seg_AC = trop_max_plus(seg_AB, seg_BC)

    print(f"Segment A→B delays:\n{seg_AB}")
    print(f"Segment B→C delays:\n{seg_BC}")
    print(f"End-to-end A→C (max-plus product):\n{seg_AC}")

    # Verify: (0,0) = max(4+2, 6+8) = max(6,14) = 14
    #         (0,1) = max(4+7, 6+1) = max(11,7) = 11
    #         (1,0) = max(5+2, 3+8) = max(7,11) = 11
    #         (1,1) = max(5+7, 3+1) = max(12,4) = 12
    expected = np.array([[14, 11], [11, 12]])
    print(f"Expected:\n{expected}")
    print(f"✓ Verified: {np.allclose(seg_AC, expected)}")

    bound_AB = np.max(seg_AB)  # 6
    bound_BC = np.max(seg_BC)  # 8
    bound_AC = np.max(seg_AC)  # 14
    print(f"\nCycle-time bounds: A→B={bound_AB}, B→C={bound_BC}")
    print(f"Certified series bound: {bound_AB + bound_BC}")
    print(f"Actual max delay: {bound_AC}")
    print(f"✓ Compositional bound holds: {bound_AC <= bound_AB + bound_BC}")
    print()


if __name__ == "__main__":
    demo_series_composition()
    demo_series_2x2()
    demo_parallel_shared()
    demo_parallel_disjoint()
    demo_throughput_certification()
    demo_associativity()
    demo_railway_scheduling()
    print("All demonstrations completed successfully!")


#!/usr/bin/env python3
"""
Visualizations for Compositional Tropical Event-Graph Semantics
Generates figures as base64-encoded PNGs for embedding in the JSON package.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyArrowPatch
import io
import base64


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_series_composition() -> str:
    """Visualize series composition = tropical matrix multiplication."""
    fig, axes = plt.subplots(1, 3, figsize=(14, 4))

    # G1
    ax = axes[0]
    ax.set_title("Stage 1: G₁", fontsize=14, fontweight='bold')
    data1 = np.array([[1, 3], [2, 4]])
    im = ax.imshow(data1, cmap='YlOrRd', aspect='equal')
    for i in range(2):
        for j in range(2):
            ax.text(j, i, str(data1[i, j]), ha='center', va='center', fontsize=16, fontweight='bold')
    ax.set_xticks([0, 1]); ax.set_xticklabels(['β₁', 'β₂'])
    ax.set_yticks([0, 1]); ax.set_yticklabels(['α₁', 'α₂'])
    ax.set_xlabel("Output"); ax.set_ylabel("Input")

    # G2
    ax = axes[1]
    ax.set_title("Stage 2: G₂", fontsize=14, fontweight='bold')
    data2 = np.array([[5, 6], [7, 8]])
    ax.imshow(data2, cmap='YlOrRd', aspect='equal')
    for i in range(2):
        for j in range(2):
            ax.text(j, i, str(data2[i, j]), ha='center', va='center', fontsize=16, fontweight='bold')
    ax.set_xticks([0, 1]); ax.set_xticklabels(['γ₁', 'γ₂'])
    ax.set_yticks([0, 1]); ax.set_yticklabels(['β₁', 'β₂'])
    ax.set_xlabel("Output"); ax.set_ylabel("Input")

    # Result
    ax = axes[2]
    ax.set_title("G₁ ⊗ G₂ (Max-Plus)", fontsize=14, fontweight='bold')
    result = np.array([[10, 11], [11, 12]])
    ax.imshow(result, cmap='YlOrRd', aspect='equal')
    for i in range(2):
        for j in range(2):
            ax.text(j, i, str(result[i, j]), ha='center', va='center', fontsize=16, fontweight='bold', color='white')
    ax.set_xticks([0, 1]); ax.set_xticklabels(['γ₁', 'γ₂'])
    ax.set_yticks([0, 1]); ax.set_yticklabels(['α₁', 'α₂'])
    ax.set_xlabel("Output"); ax.set_ylabel("Input")

    fig.suptitle("Series Composition = Tropical Matrix Multiplication", fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def viz_parallel_composition() -> str:
    """Visualize parallel (shared) composition = pointwise max."""
    fig, axes = plt.subplots(1, 3, figsize=(14, 4))

    data1 = np.array([[2, 1], [3, 2]])
    data2 = np.array([[1, 4], [2, 3]])
    result = np.maximum(data1, data2)

    for ax, data, title in zip(axes, [data1, data2, result],
                                ["Path A: G₁", "Path B: G₂", "G₁ ⊕ G₂ (Pointwise Max)"]):
        ax.set_title(title, fontsize=14, fontweight='bold')
        cmap = 'Blues' if title != "G₁ ⊕ G₂ (Pointwise Max)" else 'Purples'
        ax.imshow(data, cmap=cmap, aspect='equal', vmin=0, vmax=5)
        for i in range(2):
            for j in range(2):
                ax.text(j, i, str(data[i, j]), ha='center', va='center', fontsize=16, fontweight='bold')
        ax.set_xticks([0, 1]); ax.set_xticklabels(['κ₁', 'κ₂'])
        ax.set_yticks([0, 1]); ax.set_yticklabels(['ι₁', 'ι₂'])

    fig.suptitle("Shared Parallel Composition = Tropical Addition (Pointwise Max)",
                 fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def viz_throughput_certification() -> str:
    """Visualize compositional throughput bound propagation."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 6))

    # Network: (G1 → G2) ∥ (G3 → G4) → G5
    boxes = {
        'G₁': (1, 3, 'c₁=3'),
        'G₂': (3, 3, 'c₂=5'),
        'G₃': (1, 1, 'c₃=4'),
        'G₄': (3, 1, 'c₄=2'),
        'G₅': (6, 2, 'c₅=6'),
    }

    colors = {'G₁': '#3498db', 'G₂': '#e74c3c', 'G₃': '#2ecc71',
              'G₄': '#f39c12', 'G₅': '#9b59b6'}

    for name, (x, y, label) in boxes.items():
        rect = mpatches.FancyBboxPatch((x-0.4, y-0.3), 0.8, 0.6,
                                        boxstyle="round,pad=0.05",
                                        facecolor=colors[name], alpha=0.8,
                                        edgecolor='black', linewidth=2)
        ax.add_patch(rect)
        ax.text(x, y+0.05, name, ha='center', va='center', fontsize=14,
                fontweight='bold', color='white')
        ax.text(x, y-0.15, label, ha='center', va='center', fontsize=10,
                color='white')

    # Arrows
    arrows = [
        ((1.4, 3), (2.6, 3)),    # G1 → G2
        ((1.4, 1), (2.6, 1)),    # G3 → G4
        ((3.4, 3), (5.6, 2.2)),  # G2 → G5
        ((3.4, 1), (5.6, 1.8)),  # G4 → G5
    ]

    for (x1, y1), (x2, y2) in arrows:
        ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                   arrowprops=dict(arrowstyle='->', lw=2, color='#333'))

    # Composition labels
    ax.text(2, 3.6, 'series: 3+5=8', ha='center', fontsize=11, color='#e74c3c', fontstyle='italic')
    ax.text(2, 0.4, 'series: 4+2=6', ha='center', fontsize=11, color='#f39c12', fontstyle='italic')
    ax.text(4.8, 2.8, 'parallel: max(8,6)=8', ha='center', fontsize=11, color='#9b59b6', fontstyle='italic')
    ax.text(7.2, 2, 'series: 8+6=14', ha='center', fontsize=11, color='#333', fontweight='bold')

    # Final bound
    ax.text(6, 0.3, 'Certified bound: 14', ha='center', fontsize=14,
            fontweight='bold', color='#9b59b6',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#f8f9fa', edgecolor='#9b59b6', linewidth=2))

    ax.set_xlim(0, 8.5)
    ax.set_ylim(-0.2, 4.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title("Compositional Throughput Certification", fontsize=16, fontweight='bold')

    return fig_to_base64(fig)


def viz_tropical_power_convergence() -> str:
    """Visualize convergence of tropical matrix powers (cycle mean)."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    from algorithms import trop_matmul, max_cycle_mean, NEG_INF

    # Matrix with known cycle mean
    A = np.array([[NEG_INF, 3, NEG_INF],
                   [NEG_INF, NEG_INF, 2],
                   [4, NEG_INF, NEG_INF]])

    # Track max entries of A^k / k
    powers = []
    current = np.full((3, 3), NEG_INF)
    np.fill_diagonal(current, 0.0)

    max_entries = []
    normalized_max = []

    for k in range(1, 16):
        current = trop_matmul(current, A)
        valid = current[current > NEG_INF]
        if len(valid) > 0:
            mx = np.max(valid)
            max_entries.append(mx)
            normalized_max.append(mx / k)
        else:
            max_entries.append(NEG_INF)
            normalized_max.append(NEG_INF)

    ks = range(1, 16)
    mcm = max_cycle_mean(A)

    ax1.plot(ks, max_entries, 'bo-', linewidth=2, markersize=8, label='max(A^k)')
    ax1.set_xlabel('Power k', fontsize=12)
    ax1.set_ylabel('Maximum Entry', fontsize=12)
    ax1.set_title('Tropical Matrix Powers', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    ax2.plot(ks, normalized_max, 'ro-', linewidth=2, markersize=8, label='max(A^k) / k')
    ax2.axhline(y=mcm, color='green', linestyle='--', linewidth=2, label=f'MCM = {mcm:.2f}')
    ax2.set_xlabel('Power k', fontsize=12)
    ax2.set_ylabel('Normalized Maximum', fontsize=12)
    ax2.set_title('Convergence to Maximum Cycle Mean', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    fig.suptitle("Tropical Spectral Theory: Power Convergence", fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def viz_pipeline_architecture() -> str:
    """Visualize the compositional network architecture."""
    fig, ax = plt.subplots(1, 1, figsize=(14, 5))

    # Draw pipeline stages
    stage_info = [
        (1, 2, 'Fetch\n(3,2,1,4)', '#3498db'),
        (4, 2, 'Decode\n(2,5,1,3,2,4)', '#e74c3c'),
        (7, 2, 'Execute\n(4,3,2,6,5,1)', '#2ecc71'),
        (10, 2, 'Write\n(2,3)', '#f39c12'),
    ]

    for x, y, label, color in stage_info:
        rect = mpatches.FancyBboxPatch((x-0.7, y-0.5), 1.4, 1.0,
                                        boxstyle="round,pad=0.1",
                                        facecolor=color, alpha=0.85,
                                        edgecolor='black', linewidth=2)
        ax.add_patch(rect)
        ax.text(x, y, label, ha='center', va='center', fontsize=10,
                fontweight='bold', color='white')

    # Arrows with labels
    arrow_data = [
        (1.7, 2, 3.3, 2, '⊗'),
        (4.7, 2, 6.3, 2, '⊗'),
        (7.7, 2, 9.3, 2, '⊗'),
    ]

    for x1, y1, x2, y2, label in arrow_data:
        ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                   arrowprops=dict(arrowstyle='->', lw=3, color='#333'))
        ax.text((x1+x2)/2, y2+0.4, label, ha='center', fontsize=16, fontweight='bold', color='#333')

    # Bounds
    bounds = [(1, 0.8, 'c₁=4'), (4, 0.8, 'c₂=5'), (7, 0.8, 'c₃=6'), (10, 0.8, 'c₄=3')]
    for x, y, label in bounds:
        ax.text(x, y, label, ha='center', fontsize=11, color='#666', fontstyle='italic')

    ax.text(5.5, 0.2, 'Certified End-to-End Bound: c₁ + c₂ + c₃ + c₄ = 4 + 5 + 6 + 3 = 18 ns',
            ha='center', fontsize=13, fontweight='bold', color='#9b59b6',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#f8f9fa', edgecolor='#9b59b6', linewidth=2))

    ax.set_xlim(-0.5, 12)
    ax.set_ylim(-0.3, 3.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title("4-Stage Hardware Pipeline with Compositional Timing Certification",
                 fontsize=16, fontweight='bold')

    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    viz1 = viz_series_composition()
    print(f"  Series composition: {len(viz1)} chars")
    viz2 = viz_parallel_composition()
    print(f"  Parallel composition: {len(viz2)} chars")
    viz3 = viz_throughput_certification()
    print(f"  Throughput certification: {len(viz3)} chars")
    viz4 = viz_tropical_power_convergence()
    print(f"  Power convergence: {len(viz4)} chars")
    viz5 = viz_pipeline_architecture()
    print(f"  Pipeline architecture: {len(viz5)} chars")
    print("All visualizations generated successfully!")
