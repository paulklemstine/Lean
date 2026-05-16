#!/usr/bin/env python3
"""
Tropical Neural Code Classification — Real-World Applications

Demonstrates how the tropical neural coding framework applies to:
1. Hippocampal place cell decoding
2. Visual cortex orientation selectivity
3. Sensor array classification
4. Robustness certification under noise
"""

import numpy as np
from itertools import combinations
from typing import Tuple


def tropical_class_margin(A: np.ndarray, B: np.ndarray) -> float:
    """Tropical class margin between codebooks A and B."""
    if len(A) == 0 or len(B) == 0:
        return 0.0
    diffs = A[:, np.newaxis, :] - B[np.newaxis, :, :]
    return float(np.min(np.max(diffs, axis=2)))


def global_tropical_margin(X: np.ndarray, labels: np.ndarray) -> float:
    """Global tropical margin of a labeled code."""
    unique = np.unique(labels)
    if len(unique) < 2:
        return 0.0
    return min(
        tropical_class_margin(X[labels == k1], X[labels == k2])
        for k1, k2 in combinations(unique, 2)
    )


def classify_tropical(X: np.ndarray, labels: np.ndarray, x: np.ndarray) -> Tuple[int, float]:
    """Classify x and return (label, margin)."""
    unique = np.unique(labels)
    scores = {}
    for k in unique:
        ck = X[labels == k]
        scores[k] = min(float(np.max(a - x)) for a in ck)
    sorted_s = sorted(scores.items(), key=lambda p: p[1])
    best = sorted_s[0][0]
    margin = sorted_s[1][1] - sorted_s[0][1] if len(sorted_s) > 1 else float('inf')
    return int(best), margin


# =====================================================================
# Application 1: Hippocampal Place Cell Decoding
# =====================================================================
print("=" * 70)
print("APPLICATION 1: Hippocampal Place Cell Decoding")
print("=" * 70)
print("""
Place cells in the hippocampus fire at specific spatial locations.
Each place cell has a 'place field' — a region where it fires maximally.
The population firing pattern encodes the animal's current location.

We model n_cells place cells, each with a Gaussian place field centered
at a random location on a linear track. The firing rate vector for
location l is [rate_1(l), rate_2(l), ..., rate_n(l)].

The tropical framework certifies how many locations can be reliably
distinguished from the population code alone.
""")

np.random.seed(42)
n_cells = 10
n_locations = 6
track_length = 100.0
field_width = 15.0

# Place field centers for each cell
cell_centers = np.random.uniform(0, track_length, n_cells)

# Generate firing rate vectors for each location
sample_positions = np.linspace(10, 90, n_locations)
X_place = []
labels_place = []

for loc_idx, pos in enumerate(sample_positions):
    for trial in range(5):  # 5 trials per location
        rates = np.exp(-0.5 * ((pos - cell_centers) / field_width) ** 2) * 20
        rates += np.random.normal(0, 0.5, n_cells)  # trial noise
        rates = np.maximum(rates, 0)
        X_place.append(rates)
        labels_place.append(loc_idx)

X_place = np.array(X_place)
labels_place = np.array(labels_place)

cap = len(np.unique(labels_place))
gm = global_tropical_margin(X_place, labels_place)

print(f"Number of place cells:    {n_cells}")
print(f"Number of locations:      {n_locations}")
print(f"Trials per location:      5")
print(f"Total population vectors: {len(X_place)}")
print(f"Classification capacity:  {cap}")
print(f"Global tropical margin:   {gm:.4f}")

if gm > 0:
    print(f"\n✓ All {cap} locations are tropically certifiable!")
    print(f"  Maximum noise tolerance: {gm/2:.4f} (per-coordinate)")
else:
    print(f"\n⚠ Some locations may not be certifiably distinct.")

# Test decoding accuracy
correct = 0
total = 0
for i in range(len(X_place)):
    pred, margin = classify_tropical(X_place, labels_place, X_place[i])
    if pred == labels_place[i]:
        correct += 1
    total += 1
print(f"\nTraining set accuracy: {correct}/{total} = {100*correct/total:.1f}%")


# =====================================================================
# Application 2: Visual Cortex Orientation Selectivity
# =====================================================================
print("\n" + "=" * 70)
print("APPLICATION 2: Visual Cortex Orientation Selectivity")
print("=" * 70)
print("""
Neurons in primary visual cortex (V1) are selective for edge orientations.
Each neuron has a preferred orientation and responds with a tuning curve.
The population code for an orientation θ is the vector of firing rates
across all orientation-selective neurons.

We demonstrate that tropical margins certify distinguishability of
discrete orientation classes.
""")

np.random.seed(7)
n_v1_neurons = 16
n_orientations = 8  # 0°, 22.5°, 45°, ..., 157.5°
preferred_orientations = np.linspace(0, np.pi, n_v1_neurons, endpoint=False)
tuning_width = np.pi / 6  # 30 degrees

orientations = np.linspace(0, np.pi, n_orientations, endpoint=False)
X_v1 = []
labels_v1 = []

for ori_idx, theta in enumerate(orientations):
    for trial in range(4):
        # Von Mises-like tuning curve
        rates = 10 * np.exp(np.cos(2 * (theta - preferred_orientations)) / tuning_width)
        rates += np.random.normal(0, 0.3, n_v1_neurons)
        rates = np.maximum(rates, 0)
        X_v1.append(rates)
        labels_v1.append(ori_idx)

X_v1 = np.array(X_v1)
labels_v1 = np.array(labels_v1)

cap = len(np.unique(labels_v1))
gm = global_tropical_margin(X_v1, labels_v1)

print(f"Number of V1 neurons:     {n_v1_neurons}")
print(f"Number of orientations:   {n_orientations}")
print(f"Classification capacity:  {cap}")
print(f"Global tropical margin:   {gm:.4f}")
print(f"Capacity ≤ code size:     {cap} ≤ {len(X_v1)}")

# Show margin structure
print(f"\nPairwise margin matrix (selected pairs):")
for i, j in [(0,1), (0,4), (0,7), (3,4), (3,7)]:
    A = X_v1[labels_v1 == i]
    B = X_v1[labels_v1 == j]
    m = tropical_class_margin(A, B)
    angle_i = orientations[i] * 180 / np.pi
    angle_j = orientations[j] * 180 / np.pi
    print(f"  {angle_i:.0f}° vs {angle_j:.0f}°: margin = {m:.4f}")


# =====================================================================
# Application 3: Robustness Certification
# =====================================================================
print("\n" + "=" * 70)
print("APPLICATION 3: Robustness Certification Under Noise")
print("=" * 70)
print("""
The tropical margin provides a certificate for robustness:
if the global margin is γ > 0, then any perturbation of size < γ/2
(in L∞ norm) is guaranteed not to change the classification.

This is the tropical analogue of certified adversarial robustness.
""")

np.random.seed(99)
# Well-separated code
X_robust = np.array([
    [10, 0, 5], [11, 1, 5], [9, 0, 6],
    [0, 10, 5], [1, 11, 4], [0, 9, 6],
    [5, 5, 10], [4, 6, 11], [6, 4, 9],
], dtype=float)
labels_robust = np.array([0, 0, 0, 1, 1, 1, 2, 2, 2])

gm = global_tropical_margin(X_robust, labels_robust)
certified_radius = gm / 2

print(f"Code: 3 classes × 3 codewords in ℝ³")
print(f"Global tropical margin: {gm:.4f}")
print(f"Certified robustness radius (L∞): {certified_radius:.4f}")

# Test with increasing perturbation
print(f"\nPerturbation test (L∞ noise):")
epsilons = [0, 0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0]
for eps in epsilons:
    n_correct = 0
    n_total = 100
    for _ in range(n_total):
        idx = np.random.randint(len(X_robust))
        x = X_robust[idx] + np.random.uniform(-eps, eps, 3)
        pred, _ = classify_tropical(X_robust, labels_robust, x)
        if pred == labels_robust[idx]:
            n_correct += 1
    cert = "CERTIFIED" if eps < certified_radius else ""
    print(f"  ε={eps:.1f}: accuracy={100*n_correct/n_total:.0f}%  {cert}")


# =====================================================================
# Application 4: Sensor Array Anomaly Detection
# =====================================================================
print("\n" + "=" * 70)
print("APPLICATION 4: Industrial Sensor Array Classification")
print("=" * 70)
print("""
An array of d sensors monitors a process with K known operating modes.
Each mode produces a characteristic sensor reading pattern.
Tropical margins certify that the operating modes are distinguishable
and provide a noise tolerance guarantee.
""")

np.random.seed(2024)
n_sensors = 6
n_modes = 4
mode_names = ["Normal", "Overheating", "Vibration", "Pressure Drop"]

# Characteristic sensor patterns for each mode
mode_patterns = {
    0: np.array([50, 50, 50, 50, 50, 50], dtype=float),   # Normal
    1: np.array([80, 70, 50, 50, 45, 45], dtype=float),   # Overheating
    2: np.array([50, 50, 70, 75, 60, 40], dtype=float),   # Vibration
    3: np.array([40, 45, 50, 30, 55, 60], dtype=float),   # Pressure Drop
}

X_sensor = []
labels_sensor = []
for mode, pattern in mode_patterns.items():
    for _ in range(10):
        reading = pattern + np.random.normal(0, 2, n_sensors)
        X_sensor.append(reading)
        labels_sensor.append(mode)

X_sensor = np.array(X_sensor)
labels_sensor = np.array(labels_sensor)

cap = len(np.unique(labels_sensor))
gm = global_tropical_margin(X_sensor, labels_sensor)

print(f"Number of sensors: {n_sensors}")
print(f"Operating modes:   {', '.join(mode_names)}")
print(f"Samples per mode:  10")
print(f"Capacity:          {cap}")
print(f"Global margin:     {gm:.4f}")
print(f"Noise tolerance:   {gm/2:.4f} per sensor")

if gm > 0:
    print(f"\n✓ All operating modes are certifiably distinguishable!")
    print(f"  Sensor readings within ±{gm/2:.1f} of nominal are guaranteed correct.")


print("\n" + "=" * 70)
print("All applications completed successfully.")
print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Neural Code Classification — Demonstrations

Concrete numerical examples showing how tropical geometry certifies
multiclass neural code classification with provable margins.
"""

import numpy as np
from itertools import combinations


def tropical_class_margin(A: np.ndarray, B: np.ndarray) -> float:
    """
    Compute the tropical class margin between two codebooks A and B.
    
    For each pair (a, b) with a in A and b in B, compute the maximum
    coordinate gap max_i (a_i - b_i). The margin is the minimum of
    these over all pairs.
    
    Args:
        A: array of shape (n_A, d), codewords of class A
        B: array of shape (n_B, d), codewords of class B
    
    Returns:
        The tropical class margin (float).
    """
    margins = []
    for a in A:
        for b in B:
            margins.append(np.max(a - b))
    return min(margins) if margins else 0.0


def global_tropical_margin(X: np.ndarray, labels: np.ndarray) -> float:
    """
    Compute the global tropical margin of a labeled code.
    
    This is the minimum pairwise tropical class margin over all
    distinct pairs of labels.
    
    Args:
        X: array of shape (n, d), the codewords
        labels: array of shape (n,), the label for each codeword
    
    Returns:
        The global tropical margin (float).
    """
    unique_labels = np.unique(labels)
    if len(unique_labels) < 2:
        return 0.0
    min_margin = float('inf')
    for k1, k2 in combinations(unique_labels, 2):
        A = X[labels == k1]
        B = X[labels == k2]
        m = tropical_class_margin(A, B)
        min_margin = min(min_margin, m)
    return min_margin


def classification_capacity(X: np.ndarray, labels: np.ndarray) -> int:
    """Number of distinct stimulus classes realized by the code."""
    return len(np.unique(labels))


def classify_tropical(X: np.ndarray, labels: np.ndarray, x: np.ndarray) -> int:
    """
    Classify observation x using tropical nearest-neighbor.
    
    The tropical score of x against class k is:
        score(x, k) = min_{a in class_k} max_i (a_i - x_i)
    
    The predicted label is the k minimizing this score.
    """
    unique_labels = np.unique(labels)
    best_label = unique_labels[0]
    best_score = float('inf')
    for k in unique_labels:
        class_k = X[labels == k]
        score = min(np.max(a - x) for a in class_k)
        if score < best_score:
            best_score = score
            best_label = k
    return best_label


# ==========================================================================
# Demo 1: Simple 2D neural code with 3 stimulus classes
# ==========================================================================
print("=" * 70)
print("DEMO 1: Simple 2D Neural Code (3 classes, 2 neurons)")
print("=" * 70)

# Three stimulus classes with distinct firing patterns
# Class 0: high firing in neuron 0, low in neuron 1
# Class 1: low firing in neuron 0, high in neuron 1
# Class 2: moderate firing in both neurons
X = np.array([
    [10.0, 1.0],   # class 0
    [9.5, 0.5],    # class 0
    [1.0, 10.0],   # class 1
    [0.5, 9.5],    # class 1
    [5.0, 5.0],    # class 2
    [5.5, 4.5],    # class 2
])
labels = np.array([0, 0, 1, 1, 2, 2])

print(f"\nCodewords (firing patterns):")
for i, (x, l) in enumerate(zip(X, labels)):
    print(f"  x_{i} = {x}  ->  stimulus class {l}")

cap = classification_capacity(X, labels)
gm = global_tropical_margin(X, labels)
print(f"\nClassification capacity: {cap}")
print(f"Global tropical margin:  {gm:.2f}")
print(f"Code size:               {len(X)}")
print(f"Capacity ≤ code size:    {cap} ≤ {len(X)} ✓")

# Show pairwise margins
print("\nPairwise tropical class margins:")
for k1, k2 in combinations(range(3), 2):
    A = X[labels == k1]
    B = X[labels == k2]
    m = tropical_class_margin(A, B)
    print(f"  margin(class {k1}, class {k2}) = {m:.2f}")

# Classify a test point
test = np.array([8.0, 2.0])
pred = classify_tropical(X, labels, test)
print(f"\nTest point {test} -> classified as stimulus {pred}")


# ==========================================================================
# Demo 2: Place cell code (simulated hippocampal place fields)
# ==========================================================================
print("\n" + "=" * 70)
print("DEMO 2: Simulated Place Cell Code (8 locations, 4 neurons)")
print("=" * 70)

np.random.seed(42)
n_locations = 8
n_neurons = 4
n_samples_per_loc = 3

# Each location has a characteristic firing pattern with noise
centers = np.random.uniform(0, 20, size=(n_locations, n_neurons))
# Add small noise to create multiple samples per location
X_place = []
labels_place = []
for loc in range(n_locations):
    for _ in range(n_samples_per_loc):
        X_place.append(centers[loc] + np.random.normal(0, 0.3, n_neurons))
        labels_place.append(loc)

X_place = np.array(X_place)
labels_place = np.array(labels_place)

cap = classification_capacity(X_place, labels_place)
gm = global_tropical_margin(X_place, labels_place)
print(f"\nNumber of neurons:       {n_neurons}")
print(f"Number of locations:     {n_locations}")
print(f"Samples per location:    {n_samples_per_loc}")
print(f"Total codewords:         {len(X_place)}")
print(f"Classification capacity: {cap}")
print(f"Global tropical margin:  {gm:.4f}")
print(f"Capacity ≤ code size:    {cap} ≤ {len(X_place)} ✓")

if gm > 0:
    print(f"\n✓ Positive global margin => certified multiclass separation!")
    print(f"  All {cap} locations are tropically distinguishable.")
else:
    print(f"\n⚠ Non-positive margin. Some locations may overlap tropically.")
    # Find which pairs overlap
    for k1, k2 in combinations(range(n_locations), 2):
        A = X_place[labels_place == k1]
        B = X_place[labels_place == k2]
        m = tropical_class_margin(A, B)
        if m <= 0:
            print(f"  Overlap: locations {k1} and {k2}, margin = {m:.4f}")


# ==========================================================================
# Demo 3: Capacity scaling — how capacity grows with neurons
# ==========================================================================
print("\n" + "=" * 70)
print("DEMO 3: Capacity Scaling with Number of Neurons")
print("=" * 70)

np.random.seed(123)
neuron_counts = [2, 4, 8, 16, 32]
n_classes = 10
n_per_class = 5

print(f"\nFixed: {n_classes} stimulus classes, {n_per_class} samples each")
print(f"{'Neurons':>8}  {'Capacity':>10}  {'Global Margin':>14}  {'Separated?':>12}")
print("-" * 50)

for n_neur in neuron_counts:
    centers = np.random.uniform(0, 10, size=(n_classes, n_neur))
    X_sc = []
    labels_sc = []
    for c in range(n_classes):
        for _ in range(n_per_class):
            X_sc.append(centers[c] + np.random.normal(0, 0.1, n_neur))
            labels_sc.append(c)
    X_sc = np.array(X_sc)
    labels_sc = np.array(labels_sc)
    
    cap = classification_capacity(X_sc, labels_sc)
    gm = global_tropical_margin(X_sc, labels_sc)
    sep = "✓" if gm > 0 else "✗"
    print(f"{n_neur:>8}  {cap:>10}  {gm:>14.4f}  {sep:>12}")


# ==========================================================================
# Demo 4: Tropical margin vs. Euclidean margin
# ==========================================================================
print("\n" + "=" * 70)
print("DEMO 4: Tropical vs. Euclidean Margin Comparison")
print("=" * 70)

def euclidean_class_margin(A, B):
    """Minimum Euclidean distance between any pair from A and B."""
    dists = []
    for a in A:
        for b in B:
            dists.append(np.linalg.norm(a - b))
    return min(dists)

# Create a code where tropical margin is more informative
X_comp = np.array([
    [10.0, 0.0, 0.0],
    [0.0, 10.0, 0.0],
    [0.0, 0.0, 10.0],
    [5.0, 5.0, 0.0],
    [0.0, 5.0, 5.0],
    [5.0, 0.0, 5.0],
])
labels_comp = np.array([0, 0, 0, 1, 1, 1])

A = X_comp[labels_comp == 0]
B = X_comp[labels_comp == 1]

trop_m = tropical_class_margin(A, B)
eucl_m = euclidean_class_margin(A, B)

print(f"\nCode with 3 neurons, 2 classes (3 codewords each):")
print(f"  Tropical class margin:  {trop_m:.4f}")
print(f"  Euclidean class margin: {eucl_m:.4f}")
print(f"\nThe tropical margin captures coordinate-wise separation structure")
print(f"that the Euclidean distance misses.")


print("\n" + "=" * 70)
print("All demonstrations completed successfully.")
print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Neural Code Classification — Visualizations

Generates publication-quality figures as base64-encoded PNGs.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from itertools import combinations
import base64
import io
import json


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def tropical_class_margin(A, B):
    if len(A) == 0 or len(B) == 0:
        return 0.0
    diffs = A[:, np.newaxis, :] - B[np.newaxis, :, :]
    return float(np.min(np.max(diffs, axis=2)))


# =====================================================================
# Figure 1: 2D Tropical Neural Code with Decision Regions
# =====================================================================
def make_fig1():
    fig, ax = plt.subplots(1, 1, figsize=(8, 7))
    
    X = np.array([
        [10, 1], [9.5, 0.5],   # class 0
        [1, 10], [0.5, 9.5],   # class 1
        [5, 5], [5.5, 4.5],    # class 2
    ], dtype=float)
    labels = np.array([0, 0, 1, 1, 2, 2])
    colors = ['#e74c3c', '#3498db', '#2ecc71']
    markers = ['o', 's', '^']
    class_names = ['Class A', 'Class B', 'Class C']
    
    # Decision regions
    xx, yy = np.meshgrid(np.linspace(-1, 12, 200), np.linspace(-1, 12, 200))
    grid = np.c_[xx.ravel(), yy.ravel()]
    
    Z = np.empty(len(grid), dtype=int)
    unique = np.unique(labels)
    for idx, pt in enumerate(grid):
        scores = {}
        for k in unique:
            ck = X[labels == k]
            scores[k] = min(float(np.max(a - pt)) for a in ck)
        Z[idx] = min(scores, key=scores.get)
    
    Z = Z.reshape(xx.shape)
    ax.contourf(xx, yy, Z, levels=[-0.5, 0.5, 1.5, 2.5], 
                colors=[c + '30' for c in colors], alpha=0.3)
    ax.contour(xx, yy, Z, levels=[0.5, 1.5], colors='gray', 
               linewidths=1.5, linestyles='--')
    
    # Plot codewords
    for k in range(3):
        mask = labels == k
        ax.scatter(X[mask, 0], X[mask, 1], c=colors[k], s=150, 
                  marker=markers[k], edgecolors='black', linewidths=1.5,
                  label=class_names[k], zorder=5)
    
    ax.set_xlabel('Neuron 1 Firing Rate', fontsize=13)
    ax.set_ylabel('Neuron 2 Firing Rate', fontsize=13)
    ax.set_title('Tropical Decision Regions for Neural Code', fontsize=15, fontweight='bold')
    ax.legend(fontsize=12, loc='upper right')
    ax.set_xlim(-1, 12)
    ax.set_ylim(-1, 12)
    ax.grid(True, alpha=0.3)
    
    return fig_to_base64(fig)


# =====================================================================
# Figure 2: Capacity Scaling
# =====================================================================
def make_fig2():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    np.random.seed(123)
    neuron_counts = [2, 3, 4, 6, 8, 12, 16, 24, 32]
    n_classes = 10
    n_per_class = 5
    
    margins = []
    for n_neur in neuron_counts:
        centers = np.random.uniform(0, 10, size=(n_classes, n_neur))
        X = []
        labels = []
        for c in range(n_classes):
            for _ in range(n_per_class):
                X.append(centers[c] + np.random.normal(0, 0.1, n_neur))
                labels.append(c)
        X = np.array(X)
        labels = np.array(labels)
        unique = np.unique(labels)
        gm = min(
            tropical_class_margin(X[labels == k1], X[labels == k2])
            for k1, k2 in combinations(unique, 2)
        )
        margins.append(gm)
    
    ax1.plot(neuron_counts, margins, 'o-', color='#e74c3c', linewidth=2, markersize=8)
    ax1.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax1.fill_between(neuron_counts, 0, margins, 
                     where=[m > 0 for m in margins], 
                     color='#2ecc71', alpha=0.15, label='Certifiably separated')
    ax1.fill_between(neuron_counts, margins, 0,
                     where=[m <= 0 for m in margins],
                     color='#e74c3c', alpha=0.15, label='Not certifiable')
    ax1.set_xlabel('Number of Neurons', fontsize=13)
    ax1.set_ylabel('Global Tropical Margin', fontsize=13)
    ax1.set_title('Tropical Margin vs. Neuron Count', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    
    # Capacity vs code size
    class_counts = [3, 5, 8, 10, 15, 20]
    n_neur_fixed = 16
    caps = []
    sizes = []
    for nc in class_counts:
        n_per = 5
        centers = np.random.uniform(0, 10, size=(nc, n_neur_fixed))
        X = []
        labels = []
        for c in range(nc):
            for _ in range(n_per):
                X.append(centers[c] + np.random.normal(0, 0.1, n_neur_fixed))
                labels.append(c)
        caps.append(nc)
        sizes.append(nc * n_per)
    
    ax2.bar(range(len(class_counts)), sizes, color='#3498db', alpha=0.4, label='Code size |X|')
    ax2.bar(range(len(class_counts)), caps, color='#e74c3c', alpha=0.7, label='Capacity')
    ax2.set_xticks(range(len(class_counts)))
    ax2.set_xticklabels(class_counts)
    ax2.set_xlabel('Number of Stimulus Classes', fontsize=13)
    ax2.set_ylabel('Count', fontsize=13)
    ax2.set_title('Capacity ≤ Code Size (Theorem)', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    return fig_to_base64(fig)


# =====================================================================
# Figure 3: Margin Matrix Heatmap
# =====================================================================
def make_fig3():
    fig, ax = plt.subplots(1, 1, figsize=(8, 7))
    
    X = np.array([
        [10, 1, 3], [9, 2, 3],
        [1, 10, 3], [2, 9, 4],
        [3, 3, 10], [4, 2, 9],
        [7, 7, 1], [6, 8, 2],
    ], dtype=float)
    labels = np.array([0, 0, 1, 1, 2, 2, 3, 3])
    
    unique = np.unique(labels)
    K = len(unique)
    M = np.zeros((K, K))
    for i, k1 in enumerate(unique):
        for j, k2 in enumerate(unique):
            if i != j:
                M[i, j] = tropical_class_margin(X[labels == k1], X[labels == k2])
    
    im = ax.imshow(M, cmap='RdYlGn', aspect='equal')
    plt.colorbar(im, ax=ax, label='Tropical Class Margin')
    
    for i in range(K):
        for j in range(K):
            color = 'white' if abs(M[i, j]) > 3 else 'black'
            ax.text(j, i, f'{M[i, j]:.1f}', ha='center', va='center',
                   fontsize=14, fontweight='bold', color=color)
    
    ax.set_xticks(range(K))
    ax.set_yticks(range(K))
    ax.set_xticklabels([f'Class {k}' for k in unique], fontsize=12)
    ax.set_yticklabels([f'Class {k}' for k in unique], fontsize=12)
    ax.set_title('Pairwise Tropical Class Margin Matrix', fontsize=15, fontweight='bold')
    
    return fig_to_base64(fig)


# =====================================================================
# Figure 4: Robustness Certificate
# =====================================================================
def make_fig4():
    fig, ax = plt.subplots(1, 1, figsize=(9, 6))
    
    np.random.seed(99)
    X = np.array([
        [10, 0, 5], [11, 1, 5], [9, 0, 6],
        [0, 10, 5], [1, 11, 4], [0, 9, 6],
        [5, 5, 10], [4, 6, 11], [6, 4, 9],
    ], dtype=float)
    labels = np.array([0, 0, 0, 1, 1, 1, 2, 2, 2])
    
    unique = np.unique(labels)
    gm = min(
        tropical_class_margin(X[labels == k1], X[labels == k2])
        for k1, k2 in combinations(unique, 2)
    )
    cert_radius = gm / 2
    
    epsilons = np.linspace(0, 6, 25)
    accuracies = []
    for eps in epsilons:
        n_correct = 0
        n_total = 200
        for _ in range(n_total):
            idx = np.random.randint(len(X))
            x = X[idx] + np.random.uniform(-eps, eps, 3)
            scores = {}
            for k in unique:
                ck = X[labels == k]
                scores[k] = min(float(np.max(a - x)) for a in ck)
            pred = min(scores, key=scores.get)
            if pred == labels[idx]:
                n_correct += 1
        accuracies.append(n_correct / n_total)
    
    ax.plot(epsilons, accuracies, 'o-', color='#3498db', linewidth=2, markersize=5)
    ax.axvline(x=cert_radius, color='#e74c3c', linestyle='--', linewidth=2,
              label=f'Certified radius = γ/2 = {cert_radius:.1f}')
    ax.fill_between(epsilons, 0, 1, where=epsilons <= cert_radius,
                   color='#2ecc71', alpha=0.15)
    ax.annotate('Certified\nregion', xy=(cert_radius/2, 0.5), fontsize=13,
               ha='center', color='#27ae60', fontweight='bold')
    
    ax.set_xlabel('Perturbation Size ε (L∞)', fontsize=13)
    ax.set_ylabel('Classification Accuracy', fontsize=13)
    ax.set_title('Robustness Certificate from Tropical Margin', fontsize=15, fontweight='bold')
    ax.set_ylim(-0.05, 1.05)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    
    viz1 = make_fig1()
    print(f"  Figure 1: Decision regions ({len(viz1)} chars)")
    
    viz2 = make_fig2()
    print(f"  Figure 2: Capacity scaling ({len(viz2)} chars)")
    
    viz3 = make_fig3()
    print(f"  Figure 3: Margin matrix ({len(viz3)} chars)")
    
    viz4 = make_fig4()
    print(f"  Figure 4: Robustness ({len(viz4)} chars)")
    
    # Save visualization data for PACKAGE.json
    viz_data = [
        {"name": "Tropical Decision Regions", "data": viz1},
        {"name": "Capacity Scaling Analysis", "data": viz2},
        {"name": "Pairwise Margin Matrix", "data": viz3},
        {"name": "Robustness Certificate", "data": viz4},
    ]
    
    with open("viz_data.json", "w") as f:
        json.dump(viz_data, f)
    
    print("All visualizations generated and saved.")
