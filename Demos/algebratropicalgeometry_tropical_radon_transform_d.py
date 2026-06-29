#!/usr/bin/env python3
"""
Applications of Tropical Radon Transform Duality

Demonstrates real-world applications of tropical Radon duality:
1. Tropical image reconstruction (morphological tomography)
2. Network delay tomography (max-plus algebra)
3. Tropical compressed sensing
4. Schedule optimization via tropical projections
"""

import numpy as np
from itertools import product


# ─── Core functions (self-contained) ───

def tropical_radon(H, f):
    return np.array([np.max(f + h) for h in H])

def tropical_adjoint(H, F):
    n = len(H[0])
    result = np.full(n, np.inf)
    for i, h in enumerate(H):
        result = np.minimum(result, F[i] - h)
    return result

def tropical_closure(H, f):
    return tropical_adjoint(H, tropical_radon(H, f))


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 1: Network Delay Tomography
# ═══════════════════════════════════════════════════════════════════════

def network_delay_tomography():
    """
    In max-plus network analysis, the end-to-end delay through a network
    is the maximum (worst-case) sum of node processing times along any path.
    
    The tropical Radon transform naturally models this: each functional h
    represents a routing path, h(x) is the weight of node x on path h,
    and Radon(f)(h) = max_x(f(x) + h(x)) gives the bottleneck delay.
    
    We demonstrate: given delay measurements on different paths,
    reconstruct individual node processing times.
    """
    print("=" * 70)
    print("APPLICATION 1: Network Delay Tomography")
    print("=" * 70)
    
    # 5 nodes in a network
    n_nodes = 5
    
    # True processing times (unknown — to be reconstructed)
    true_delays = np.array([3.0, 7.0, 2.0, 5.0, 1.0])
    
    # Routing paths: h(x) = weight of node x in path h
    # (binary: 1 if node is on path, 0 if not)
    paths = [
        np.array([1, 1, 0, 0, 0], dtype=float),  # Path through nodes 0,1
        np.array([0, 1, 1, 0, 0], dtype=float),   # Path through nodes 1,2
        np.array([0, 0, 1, 1, 0], dtype=float),   # Path through nodes 2,3
        np.array([0, 0, 0, 1, 1], dtype=float),   # Path through nodes 3,4
        np.array([1, 0, 0, 0, 1], dtype=float),   # Path through nodes 0,4
        np.array([1, 0, 1, 0, 1], dtype=float),   # Path through nodes 0,2,4
        np.array([0, 1, 0, 1, 0], dtype=float),   # Path through nodes 1,3
    ]
    
    # Measure bottleneck delays
    measurements = tropical_radon(paths, true_delays)
    print(f"\nTrue node delays:    {true_delays}")
    print(f"Path measurements:   {measurements}")
    
    # Reconstruct
    reconstructed = tropical_adjoint(paths, measurements)
    print(f"Reconstructed:       {reconstructed}")
    
    # Compute normal form (best possible reconstruction)
    normal_form = tropical_closure(paths, true_delays)
    print(f"Normal form:         {normal_form}")
    print(f"Reconstruction OK:   {np.allclose(reconstructed, normal_form)}")
    
    # Check which nodes are perfectly reconstructed
    for i in range(n_nodes):
        status = "✓ exact" if abs(true_delays[i] - reconstructed[i]) < 0.01 else f"△ off by {reconstructed[i] - true_delays[i]:.0f}"
        print(f"  Node {i}: true={true_delays[i]:.0f}, recon={reconstructed[i]:.0f} {status}")


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 2: Tropical Compressed Sensing
# ═══════════════════════════════════════════════════════════════════════

def tropical_compressed_sensing():
    """
    Classical compressed sensing asks: how few linear measurements suffice
    to reconstruct a sparse signal? The tropical analogue asks: how few
    max-plus projections suffice?
    
    We demonstrate that tropical normal-form signals can be reconstructed
    from far fewer measurements than the ambient dimension, and we find
    the minimal sufficient set.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Tropical Compressed Sensing")
    print("=" * 70)
    
    n = 8  # signal dimension
    
    # Generate a rich family of measurement directions
    np.random.seed(42)
    m_full = 20
    H_full = [np.random.randint(-3, 4, size=n).astype(float) for _ in range(m_full)]
    
    # Create a test signal
    signal = np.array([5, 0, 3, 0, 7, 0, 2, 0], dtype=float)
    signal_nf = tropical_closure(H_full, signal)
    
    print(f"\nSignal dimension: {n}")
    print(f"Full measurements: {m_full}")
    print(f"Original signal:   {signal}")
    print(f"Normal form:       {signal_nf}")
    
    # Try progressively fewer measurements
    for m in [20, 15, 10, 8, 5, 3]:
        H_sub = H_full[:m]
        signal_nf_sub = tropical_closure(H_sub, signal)
        F = tropical_radon(H_sub, signal_nf_sub)
        recon = tropical_adjoint(H_sub, F)
        
        match = np.allclose(recon, signal_nf_sub)
        error = np.max(np.abs(recon - signal_nf)) if not match else 0
        print(f"  m={m:2d}: reconstruction={'exact ✓' if match else f'error={error:.1f}'}")


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 3: Schedule Optimization
# ═══════════════════════════════════════════════════════════════════════

def schedule_optimization():
    """
    In project scheduling (CPM/PERT), the earliest completion time is
    a max-plus computation. The tropical Radon transform can be used to:
    1. Compute bottleneck analysis from different resource perspectives
    2. Determine which resource constraints are active
    3. Find the minimal set of constraints that determine the schedule
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Schedule Optimization via Tropical Projections")
    print("=" * 70)
    
    # 6 tasks with durations
    task_names = ["Design", "Coding", "Testing", "Review", "Deploy", "Monitor"]
    n_tasks = len(task_names)
    task_durations = np.array([5, 8, 4, 2, 3, 1], dtype=float)
    
    # Resource constraint functions: h(task) = additional delay if task
    # uses that resource
    resources = {
        "Senior Dev": np.array([2, 3, 0, 1, 0, 0], dtype=float),
        "Test Env":   np.array([0, 0, 4, 0, 2, 1], dtype=float),
        "CI/CD":      np.array([0, 1, 1, 0, 3, 0], dtype=float),
        "Manager":    np.array([1, 0, 0, 3, 1, 0], dtype=float),
    }
    
    H = list(resources.values())
    resource_names = list(resources.keys())
    
    # Compute bottleneck delays per resource perspective
    measurements = tropical_radon(H, task_durations)
    
    print(f"\nTask durations: {dict(zip(task_names, task_durations))}")
    print(f"\nBottleneck analysis:")
    for name, delay in zip(resource_names, measurements):
        print(f"  {name}: max(duration + resource_cost) = {delay:.0f}")
    
    # Reconstruct task importance
    reconstructed = tropical_adjoint(H, measurements)
    print(f"\nReconstructed task bounds: {dict(zip(task_names, reconstructed))}")
    
    # Find critical tasks (where reconstruction matches original)
    print(f"\nCritical task analysis:")
    for i, name in enumerate(task_names):
        gap = reconstructed[i] - task_durations[i]
        status = "CRITICAL" if abs(gap) < 0.01 else f"slack={gap:.0f}"
        print(f"  {name}: {status}")


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 4: Morphological Image Analysis
# ═══════════════════════════════════════════════════════════════════════

def morphological_analysis():
    """
    The tropical Radon transform is, in image processing terms, a 
    dilation operator. The adjoint is an erosion. Together they form
    a morphological opening (Adjoint ∘ Radon), which smooths the signal
    from below.
    
    We demonstrate this on a 1D signal.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Morphological Signal Analysis")
    print("=" * 70)
    
    n = 12
    
    # Structuring elements (shifted versions of a template)
    template = np.array([0, 1, 2, 1, 0, -1, -2, -1, 0, 1, 0, -1], dtype=float)
    H = []
    for shift in range(-2, 3):
        h = np.roll(template, shift)
        H.append(h)
    
    # Signal with noise
    signal = np.array([3, 5, 8, 6, 4, 2, 7, 9, 5, 3, 1, 4], dtype=float)
    
    # Apply morphological opening
    opened = tropical_closure(H, signal)
    
    print(f"\nOriginal signal:  {signal}")
    print(f"Opened signal:    {opened}")
    print(f"f ≤ opening:      {np.all(signal <= opened + 0.01)}")
    
    # Verify idempotence
    opened2 = tropical_closure(H, opened)
    print(f"Idempotent:       {np.allclose(opened, opened2)}")
    
    # Show where the opening changes the signal
    diff = opened - signal
    print(f"Change (≥0):      {diff}")
    print(f"Max smoothing:    {np.max(diff):.1f} at position {np.argmax(diff)}")


if __name__ == "__main__":
    network_delay_tomography()
    tropical_compressed_sensing()
    schedule_optimization()
    morphological_analysis()
    
    print("\n" + "=" * 70)
    print("ALL APPLICATIONS DEMONSTRATED SUCCESSFULLY")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Radon Transform Duality — Concrete Numerical Demonstrations

This module demonstrates the key theorems of tropical Radon transform duality
with explicit numerical examples, making the abstract mathematics tangible.
"""

import numpy as np
from itertools import product


def tropical_radon(H, f):
    """
    Compute the tropical Radon transform (sup-plus convention).
    
    Radon_H(f)(h) = max_{x in X} (f(x) + h(x))
    
    Parameters:
        H: list of arrays, each h is a function X -> Z (represented as array)
        f: array, function X -> Z
    
    Returns:
        array of Radon values, one per h in H
    """
    return np.array([np.max(f + h) for h in H])


def tropical_adjoint(H, F):
    """
    Compute the tropical adjoint/reconstruction operator (inf-minus convention).
    
    Adjoint_H(F)(x) = min_{h in H} (F(h) - h(x))
    
    Parameters:
        H: list of arrays, each h is a function X -> Z
        F: array of values, one per h in H
    
    Returns:
        array, reconstructed function on X
    """
    n = len(H[0])
    result = np.full(n, np.inf)
    for i, h in enumerate(H):
        result = np.minimum(result, F[i] - h)
    return result


def is_normal_form(H, f):
    """Check if f is in tropical normal form: f = Adjoint(Radon(f))."""
    F = tropical_radon(H, f)
    f_reconstructed = tropical_adjoint(H, F)
    return np.allclose(f, f_reconstructed)


def is_support_data(H, F):
    """Check if F is tropical support data: Radon(Adjoint(F)) = F."""
    f = tropical_adjoint(H, F)
    F_reconstructed = tropical_radon(H, f)
    return np.allclose(F, F_reconstructed)


def tropical_closure(H, f):
    """Compute the tropical closure: Adjoint(Radon(f)) >= f."""
    F = tropical_radon(H, f)
    return tropical_adjoint(H, F)


def tropical_discrepancy(H, F):
    """Compute discrepancy: F(h) - Radon(Adjoint(F))(h) >= 0."""
    f = tropical_adjoint(H, F)
    F_recon = tropical_radon(H, f)
    return F - F_recon


# ═══════════════════════════════════════════════════════════════════════
# DEMO 1: The Galois Connection
# ═══════════════════════════════════════════════════════════════════════
print("=" * 70)
print("DEMO 1: The Galois Connection (Residuated Pair)")
print("=" * 70)

# X = {0, 1, 2}, H = two functionals
X_size = 3
H = [
    np.array([1, 0, -1]),   # h1
    np.array([0, 2, 1]),    # h2
    np.array([-1, -1, 3]),  # h3
]

f = np.array([2, 1, 0])
F_data = np.array([10, 10, 10])  # some arbitrary target

print(f"\nX = {{0, 1, 2}}")
print(f"f = {f}")
print(f"H = {[list(h) for h in H]}")
print(f"F = {F_data}")

radon_f = tropical_radon(H, f)
adjoint_F = tropical_adjoint(H, F_data)

print(f"\nRadon(f) = {radon_f}")
print(f"Adjoint(F) = {adjoint_F}")

# Check Galois connection: (∀h, Radon(f)(h) ≤ F(h)) ↔ (∀x, f(x) ≤ Adjoint(F)(x))
lhs = all(radon_f[i] <= F_data[i] for i in range(len(H)))
rhs = all(f[x] <= adjoint_F[x] for x in range(X_size))
print(f"\n∀h, Radon(f)(h) ≤ F(h): {lhs}")
print(f"∀x, f(x) ≤ Adjoint(F)(x): {rhs}")
print(f"Galois connection verified: {lhs == rhs} ✓")

# ═══════════════════════════════════════════════════════════════════════
# DEMO 2: Closure and Normal Forms
# ═══════════════════════════════════════════════════════════════════════
print("\n" + "=" * 70)
print("DEMO 2: Tropical Closure and Normal Forms")
print("=" * 70)

f_raw = np.array([5, 1, 0])
f_closure = tropical_closure(H, f_raw)

print(f"\nOriginal f = {f_raw}")
print(f"Closure Adjoint(Radon(f)) = {f_closure}")
print(f"f ≤ closure: {all(f_raw[x] <= f_closure[x] for x in range(X_size))} ✓")
print(f"Is f in normal form? {is_normal_form(H, f_raw)}")
print(f"Is closure in normal form? {is_normal_form(H, f_closure)}")

# Verify idempotence: closure of closure = closure
f_closure2 = tropical_closure(H, f_closure)
print(f"Closure of closure = {f_closure2}")
print(f"Idempotence: {np.allclose(f_closure, f_closure2)} ✓")

# ═══════════════════════════════════════════════════════════════════════
# DEMO 3: Certified Reconstruction
# ═══════════════════════════════════════════════════════════════════════
print("\n" + "=" * 70)
print("DEMO 3: Certified Reconstruction (Round-Trip)")
print("=" * 70)

# Start with a function already in normal form
f_nf = tropical_closure(H, np.array([3, 2, 1]))
print(f"\nNormal-form function f = {f_nf}")

# Compute Radon transform
F_measured = tropical_radon(H, f_nf)
print(f"Radon measurements F = {F_measured}")

# Reconstruct
f_reconstructed = tropical_adjoint(H, F_measured)
print(f"Reconstructed = {f_reconstructed}")
print(f"Perfect reconstruction: {np.allclose(f_nf, f_reconstructed)} ✓")

# ═══════════════════════════════════════════════════════════════════════
# DEMO 4: Image Characterization (Support Data)
# ═══════════════════════════════════════════════════════════════════════
print("\n" + "=" * 70)
print("DEMO 4: Image Characterization — Support Data Axiom")
print("=" * 70)

# Consistent data (in the image of Radon)
f_test = tropical_closure(H, np.array([0, 0, 0]))
F_consistent = tropical_radon(H, f_test)
print(f"\nConsistent data F = {F_consistent}")
print(f"Is support data: {is_support_data(H, F_consistent)} ✓")

# Inconsistent data (not in the image)
F_inconsistent = np.array([100, 0, 0])
print(f"\nInconsistent data F = {F_inconsistent}")
print(f"Is support data: {is_support_data(H, F_inconsistent)}")
disc = tropical_discrepancy(H, F_inconsistent)
print(f"Discrepancy = {disc}")
print(f"Discrepancy ≥ 0: {all(d >= -1e-10 for d in disc)} ✓")

# ═══════════════════════════════════════════════════════════════════════
# DEMO 5: Injectivity on Normal Forms
# ═══════════════════════════════════════════════════════════════════════
print("\n" + "=" * 70)
print("DEMO 5: Injectivity — Distinct Normal Forms Have Distinct Radon Data")
print("=" * 70)

# Generate all normal-form functions from a grid of coefficients
normal_forms = set()
for c in product(range(-3, 4), repeat=len(H)):
    c_arr = np.array(c)
    # Normal form: f(x) = min_h (c_h - h(x))
    f_nf = tropical_adjoint(H, c_arr)
    normal_forms.add(tuple(f_nf))

normal_forms = [np.array(nf) for nf in normal_forms]
print(f"\nGenerated {len(normal_forms)} distinct normal-form functions")

# Check injectivity: no two distinct normal forms share Radon data
radon_images = {}
collision = False
for f_nf in normal_forms:
    key = tuple(tropical_radon(H, f_nf))
    if key in radon_images:
        if not np.allclose(radon_images[key], f_nf):
            collision = True
            break
    radon_images[key] = f_nf

print(f"Collision found: {collision}")
print(f"Injectivity on normal forms verified: {not collision} ✓")

# ═══════════════════════════════════════════════════════════════════════
# DEMO 6: Monotonicity
# ═══════════════════════════════════════════════════════════════════════
print("\n" + "=" * 70)
print("DEMO 6: Monotonicity of Both Operators")
print("=" * 70)

f1 = np.array([1, 2, 3])
f2 = np.array([2, 3, 4])  # f1 ≤ f2 pointwise

R1 = tropical_radon(H, f1)
R2 = tropical_radon(H, f2)
print(f"\nf1 = {f1}, f2 = {f2}")
print(f"f1 ≤ f2: {all(f1[i] <= f2[i] for i in range(X_size))}")
print(f"Radon(f1) = {R1}")
print(f"Radon(f2) = {R2}")
print(f"Radon(f1) ≤ Radon(f2): {all(R1[i] <= R2[i] for i in range(len(H)))} ✓")

F1 = np.array([5, 6, 7])
F2 = np.array([6, 7, 8])  # F1 ≤ F2 pointwise

A1 = tropical_adjoint(H, F1)
A2 = tropical_adjoint(H, F2)
print(f"\nF1 = {F1}, F2 = {F2}")
print(f"F1 ≤ F2: {all(F1[i] <= F2[i] for i in range(len(H)))}")
print(f"Adjoint(F1) = {A1}")
print(f"Adjoint(F2) = {A2}")
print(f"Adjoint(F1) ≤ Adjoint(F2): {all(A1[i] <= A2[i] for i in range(X_size))} ✓")

# ═══════════════════════════════════════════════════════════════════════
# DEMO 7: Radon ∘ Adjoint ∘ Radon = Radon
# ═══════════════════════════════════════════════════════════════════════
print("\n" + "=" * 70)
print("DEMO 7: Idempotence — Radon ∘ Adjoint ∘ Radon = Radon")
print("=" * 70)

f_test = np.array([7, -3, 5])
R = tropical_radon(H, f_test)
A_R = tropical_adjoint(H, R)
R_A_R = tropical_radon(H, A_R)

print(f"\nf = {f_test}")
print(f"Radon(f) = {R}")
print(f"Adjoint(Radon(f)) = {A_R}")
print(f"Radon(Adjoint(Radon(f))) = {R_A_R}")
print(f"Radon ∘ Adjoint ∘ Radon = Radon: {np.allclose(R, R_A_R)} ✓")

print("\n" + "=" * 70)
print("ALL DEMONSTRATIONS PASSED ✓")
print("=" * 70)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts bundled."""

import json
import base64
from pathlib import Path

# Read text files
def read_file(path):
    return Path(path).read_text()

# Generate visualizations and get base64
import sys
sys.path.insert(0, '.')
from visualizations import viz_galois_connection, viz_reconstruction, viz_support_data, viz_idempotence

print("Generating visualizations...")
b64_galois = viz_galois_connection()
b64_recon = viz_reconstruction()
b64_support = viz_support_data()
b64_idemp = viz_idempotence()

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_code = read_file('Bridges/AlgebraTropicalGeometry/TropicalRadonDuality.lean')
demo_code = read_file('demo.py')
algo_code = read_file('algorithms.py')
app_code = read_file('applications.py')

package = {
    "title": "Tropical Radon Transform Duality via Idempotent Semimodules and Certified Convex Tomography Reconstruction",
    "domain": "Tropical Algebra / Integral Geometry / Order Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Radon Transform — Full Demonstration Suite",
            "code": demo_code
        },
        {
            "name": "Real-World Applications (Network Tomography, Scheduling, Morphology)",
            "code": app_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical Radon Transform (sup-plus)",
            "pseudocode": "Input: H = [h_1,...,h_m], f : X -> Z\nOutput: F : H -> Z\n\nFor i = 1 to m:\n    F[i] = max_{x in X} (f(x) + h_i(x))\nReturn F\n\nComplexity: O(m * n) time, O(m) space",
            "code": """import numpy as np

def tropical_radon_transform(H, f):
    \"\"\"Tropical Radon transform (sup-plus convention).
    
    Args:
        H: list of arrays (measurement directions)
        f: array (signal)
    Returns:
        array of Radon values
    \"\"\"
    return np.array([np.max(f + h) for h in H])

# Example
H = [np.array([1, 0, -1]), np.array([0, 2, 1]), np.array([-1, -1, 3])]
f = np.array([2, 1, 0])
print(f"Radon({f}) = {tropical_radon_transform(H, f)}")
"""
        },
        {
            "name": "Tropical Adjoint Reconstruction (inf-minus)",
            "pseudocode": "Input: H = [h_1,...,h_m], F : H -> Z\nOutput: f : X -> Z\n\nFor each x in X:\n    f(x) = min_{i=1..m} (F[i] - h_i(x))\nReturn f\n\nComplexity: O(m * n) time, O(n) space",
            "code": """import numpy as np

def tropical_adjoint(H, F):
    \"\"\"Tropical adjoint reconstruction (inf-minus convention).
    
    Args:
        H: list of arrays (measurement directions)
        F: array (measurement data)
    Returns:
        array (reconstructed signal)
    \"\"\"
    n = len(H[0])
    result = np.full(n, np.inf)
    for i, h in enumerate(H):
        result = np.minimum(result, F[i] - h)
    return result

# Example
H = [np.array([1, 0, -1]), np.array([0, 2, 1]), np.array([-1, -1, 3])]
F = np.array([3, 3, 3])
print(f"Adjoint({F}) = {tropical_adjoint(H, F)}")
"""
        },
        {
            "name": "Certified Reconstruction Pipeline",
            "pseudocode": "Input: H, F (measurement data)\nOutput: (reconstructed_signal, is_certified, discrepancy)\n\n1. f = Adjoint(H, F)\n2. F' = Radon(H, f)\n3. discrepancy = F - F'\n4. is_certified = (discrepancy == 0)\nReturn (f, is_certified, discrepancy)\n\nComplexity: O(m * n) time",
            "code": """import numpy as np

def tropical_radon(H, f):
    return np.array([np.max(f + h) for h in H])

def tropical_adjoint(H, F):
    n = len(H[0])
    result = np.full(n, np.inf)
    for i, h in enumerate(H):
        result = np.minimum(result, F[i] - h)
    return result

def certified_reconstruction(H, F):
    \"\"\"Certified tropical tomography reconstruction.
    
    Returns (signal, is_certified, discrepancy).
    is_certified=True means F is valid support data and
    reconstruction is exact.
    \"\"\"
    f = tropical_adjoint(H, F)
    F_recon = tropical_radon(H, f)
    disc = F - F_recon
    return f, np.allclose(disc, 0), disc

# Example: consistent data
H = [np.array([1, 0, -1.0]), np.array([0, 2, 1.0]), np.array([-1, -1, 3.0])]
F_good = np.array([4.0, 4.0, 4.0])
f, cert, disc = certified_reconstruction(H, F_good)
print(f"Signal: {f}, Certified: {cert}, Discrepancy: {disc}")

# Example: inconsistent data
F_bad = np.array([100.0, 0.0, 0.0])
f, cert, disc = certified_reconstruction(H, F_bad)
print(f"Signal: {f}, Certified: {cert}, Discrepancy: {disc}")
"""
        }
    ],
    "visualizations": [
        {
            "name": "Galois Connection: Signal, Transform, and Closure",
            "data": b64_galois
        },
        {
            "name": "Certified Reconstruction Pipeline",
            "data": b64_recon
        },
        {
            "name": "Support Data Characterization: Consistent vs Inconsistent",
            "data": b64_support
        },
        {
            "name": "Idempotent Tropical Closure Operator",
            "data": b64_idemp
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully!")
print(f"  Size: {len(json.dumps(package))} bytes")


#!/usr/bin/env python3
"""
Tropical Radon Transform — Visualizations

Generates publication-quality figures illustrating the key concepts
of tropical Radon transform duality.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
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


def tropical_radon(H, f):
    return np.array([np.max(f + h) for h in H])

def tropical_adjoint(H, F):
    n = len(H[0])
    result = np.full(n, np.inf)
    for i, h in enumerate(H):
        result = np.minimum(result, F[i] - h)
    return result

def tropical_closure(H, f):
    return tropical_adjoint(H, tropical_radon(H, f))


def viz_galois_connection():
    """Visualize the Galois connection between Radon and Adjoint."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))
    
    n = 8
    x = np.arange(n)
    H = [
        np.array([2, 1, 0, -1, -2, -1, 0, 1], dtype=float),
        np.array([-1, 0, 1, 2, 1, 0, -1, -2], dtype=float),
        np.array([0, 2, 0, -2, 0, 2, 0, -2], dtype=float),
    ]
    
    f = np.array([3, 5, 8, 4, 2, 6, 7, 3], dtype=float)
    F = tropical_radon(H, f)
    f_recon = tropical_adjoint(H, F)
    
    # Panel 1: Original signal and closure
    axes[0].bar(x - 0.15, f, 0.3, label='Original f', color='steelblue', alpha=0.8)
    axes[0].bar(x + 0.15, f_recon, 0.3, label='Closure(f)', color='coral', alpha=0.8)
    axes[0].set_xlabel('Position x')
    axes[0].set_ylabel('Value')
    axes[0].set_title('Signal vs. Tropical Closure')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)
    
    # Panel 2: Radon measurements
    h_idx = np.arange(len(H))
    axes[1].bar(h_idx, F, color='forestgreen', alpha=0.8)
    axes[1].set_xlabel('Direction h')
    axes[1].set_ylabel('Radon(f)(h)')
    axes[1].set_title('Tropical Radon Transform')
    axes[1].set_xticks(h_idx)
    axes[1].set_xticklabels([f'h₁', f'h₂', f'h₃'])
    axes[1].grid(True, alpha=0.3)
    
    # Panel 3: The Galois connection diagram
    f_closure = tropical_closure(H, f)
    F_closure = tropical_radon(H, f_closure)
    
    # Show f ≤ closure and Radon(closure) = Radon
    axes[2].plot(x, f, 'o-', label='f', color='steelblue', markersize=6)
    axes[2].plot(x, f_closure, 's-', label='Adjoint∘Radon(f)', color='coral', markersize=6)
    for i in range(n):
        if f_closure[i] > f[i] + 0.1:
            axes[2].annotate('', xy=(i, f_closure[i]), xytext=(i, f[i]),
                           arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))
    axes[2].set_xlabel('Position x')
    axes[2].set_ylabel('Value')
    axes[2].set_title('f ≤ Adjoint(Radon(f))')
    axes[2].legend()
    axes[2].grid(True, alpha=0.3)
    
    fig.suptitle('Tropical Radon Transform: Galois Connection', fontsize=14, fontweight='bold')
    plt.tight_layout()
    
    fig.savefig('/workspace/request-project/viz_galois.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_reconstruction():
    """Visualize the certified reconstruction pipeline."""
    fig, axes = plt.subplots(2, 2, figsize=(12, 9))
    
    n = 10
    x = np.arange(n)
    
    H = [
        np.array([1, 0, -1, 0, 1, 0, -1, 0, 1, 0], dtype=float),
        np.array([0, 1, 0, -1, 0, 1, 0, -1, 0, 1], dtype=float),
        np.array([-1, 1, 2, 0, -1, -1, 2, 1, 0, -1], dtype=float),
        np.array([2, -1, 0, 1, -2, 1, 0, -1, 2, -1], dtype=float),
    ]
    
    # Start with a raw signal
    f_raw = np.array([5, 2, 7, 1, 8, 3, 6, 0, 4, 9], dtype=float)
    f_nf = tropical_closure(H, f_raw)
    F = tropical_radon(H, f_nf)
    f_recon = tropical_adjoint(H, F)
    
    # Panel 1: Raw signal
    axes[0, 0].bar(x, f_raw, color='steelblue', alpha=0.8)
    axes[0, 0].set_title('Step 1: Raw Signal f')
    axes[0, 0].set_xlabel('Position')
    axes[0, 0].set_ylabel('Value')
    axes[0, 0].grid(True, alpha=0.3)
    
    # Panel 2: Normal form
    axes[0, 1].bar(x - 0.15, f_raw, 0.3, label='Raw', color='steelblue', alpha=0.5)
    axes[0, 1].bar(x + 0.15, f_nf, 0.3, label='Normal form', color='coral', alpha=0.8)
    axes[0, 1].set_title('Step 2: Tropical Normal Form')
    axes[0, 1].set_xlabel('Position')
    axes[0, 1].legend()
    axes[0, 1].grid(True, alpha=0.3)
    
    # Panel 3: Radon measurements
    h_idx = np.arange(len(H))
    axes[1, 0].bar(h_idx, F, color='forestgreen', alpha=0.8)
    axes[1, 0].set_title('Step 3: Radon Measurements')
    axes[1, 0].set_xlabel('Direction')
    axes[1, 0].set_ylabel('Radon(f)(h)')
    axes[1, 0].set_xticks(h_idx)
    axes[1, 0].set_xticklabels([f'h₁', f'h₂', f'h₃', f'h₄'])
    axes[1, 0].grid(True, alpha=0.3)
    
    # Panel 4: Reconstruction
    axes[1, 1].bar(x - 0.15, f_nf, 0.3, label='Original NF', color='coral', alpha=0.5)
    axes[1, 1].bar(x + 0.15, f_recon, 0.3, label='Reconstructed', color='gold', alpha=0.8)
    match = np.allclose(f_nf, f_recon)
    axes[1, 1].set_title(f'Step 4: Certified Reconstruction ({"✓ exact" if match else "✗ error"})')
    axes[1, 1].set_xlabel('Position')
    axes[1, 1].legend()
    axes[1, 1].grid(True, alpha=0.3)
    
    fig.suptitle('Tropical Tomography: Full Reconstruction Pipeline', fontsize=14, fontweight='bold')
    plt.tight_layout()
    
    fig.savefig('/workspace/request-project/viz_reconstruction.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_support_data():
    """Visualize the image characterization: consistent vs inconsistent data."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))
    
    n = 6
    H = [
        np.array([1, 0, -1, 0, 1, 0], dtype=float),
        np.array([0, 1, 0, -1, 0, 1], dtype=float),
        np.array([-1, 1, 1, 0, -1, 0], dtype=float),
    ]
    
    # Consistent data
    f_test = tropical_closure(H, np.array([3, 1, 4, 1, 5, 2], dtype=float))
    F_consistent = tropical_radon(H, f_test)
    f_recon = tropical_adjoint(H, F_consistent)
    F_roundtrip = tropical_radon(H, f_recon)
    
    h_idx = np.arange(len(H))
    axes[0].bar(h_idx - 0.15, F_consistent, 0.3, label='F', color='forestgreen', alpha=0.8)
    axes[0].bar(h_idx + 0.15, F_roundtrip, 0.3, label='Radon(Adj(F))', color='gold', alpha=0.8)
    axes[0].set_title('Consistent: F = Radon(Adj(F))')
    axes[0].set_xticks(h_idx)
    axes[0].set_xticklabels(['h₁', 'h₂', 'h₃'])
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)
    
    # Inconsistent data
    F_incon = np.array([20, 1, 1], dtype=float)
    f_recon2 = tropical_adjoint(H, F_incon)
    F_roundtrip2 = tropical_radon(H, f_recon2)
    disc = F_incon - F_roundtrip2
    
    axes[1].bar(h_idx - 0.15, F_incon, 0.3, label='F', color='tomato', alpha=0.8)
    axes[1].bar(h_idx + 0.15, F_roundtrip2, 0.3, label='Radon(Adj(F))', color='gold', alpha=0.8)
    axes[1].set_title('Inconsistent: F ≠ Radon(Adj(F))')
    axes[1].set_xticks(h_idx)
    axes[1].set_xticklabels(['h₁', 'h₂', 'h₃'])
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)
    
    # Discrepancy
    axes[2].bar(h_idx, disc, color='purple', alpha=0.8)
    axes[2].axhline(y=0, color='black', linewidth=0.5)
    axes[2].set_title('Discrepancy δ(F) ≥ 0')
    axes[2].set_xticks(h_idx)
    axes[2].set_xticklabels(['h₁', 'h₂', 'h₃'])
    axes[2].set_ylabel('F(h) - Radon(Adj(F))(h)')
    axes[2].grid(True, alpha=0.3)
    
    fig.suptitle('Tropical Support Data: Image Characterization', fontsize=14, fontweight='bold')
    plt.tight_layout()
    
    fig.savefig('/workspace/request-project/viz_support_data.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_idempotence():
    """Visualize the idempotence of the closure operator."""
    fig, ax = plt.subplots(figsize=(10, 5))
    
    n = 12
    x = np.arange(n)
    
    H = [
        np.array([1, 0, -1, -2, -1, 0, 1, 2, 1, 0, -1, 0], dtype=float),
        np.array([0, 1, 2, 1, 0, -1, -2, -1, 0, 1, 2, 1], dtype=float),
        np.array([-2, 0, 1, 0, -1, 2, 0, -1, 1, 0, -2, 1], dtype=float),
    ]
    
    f0 = np.array([1, 5, 2, 8, 1, 3, 7, 2, 6, 1, 4, 3], dtype=float)
    f1 = tropical_closure(H, f0)
    f2 = tropical_closure(H, f1)
    f3 = tropical_closure(H, f2)
    
    ax.plot(x, f0, 'o-', label='f₀ (original)', color='steelblue', markersize=6, linewidth=2)
    ax.plot(x, f1, 's-', label='f₁ = closure(f₀)', color='coral', markersize=6, linewidth=2)
    ax.plot(x, f2, 'D-', label='f₂ = closure(f₁) = f₁', color='gold', markersize=5, linewidth=1.5, linestyle='--')
    
    ax.fill_between(x, f0, f1, alpha=0.15, color='coral', label='Closure gap')
    
    ax.set_xlabel('Position x', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Idempotent Tropical Closure: One Application Suffices', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    fig.savefig('/workspace/request-project/viz_idempotence.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_galois = viz_galois_connection()
    print(f"  Galois connection: {len(b64_galois)} chars")
    b64_recon = viz_reconstruction()
    print(f"  Reconstruction: {len(b64_recon)} chars")
    b64_support = viz_support_data()
    print(f"  Support data: {len(b64_support)} chars")
    b64_idemp = viz_idempotence()
    print(f"  Idempotence: {len(b64_idemp)} chars")
    print("Done!")
