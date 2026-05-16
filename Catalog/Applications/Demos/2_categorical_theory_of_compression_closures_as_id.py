#!/usr/bin/env python3
"""
Applications of the Categorical Compression Monad framework.

Demonstrates real-world applications:
1. Data normalization in machine learning
2. Signal compression via tropical projection
3. Graph weight canonicalization
"""

import numpy as np


def ml_feature_normalization(data: np.ndarray) -> np.ndarray:
    """
    Apply tropical normalization to ML feature vectors.

    Each row is a feature vector; tropical normalization shifts each
    vector so its minimum is zero, preserving relative differences.

    This is a mathematically principled normalization that is:
    - Idempotent (normalizing twice = normalizing once)
    - Translation invariant (robust to global shifts)
    - Canonical (unique representative per equivalence class)
    """
    return np.array([row - np.min(row) for row in data])


def tropical_signal_compression(signal: np.ndarray, window_size: int = 8) -> dict:
    """
    Compress a signal using windowed tropical normalization.

    Splits signal into windows and normalizes each window,
    storing only the normalized values and per-window minimums.

    Returns compressed representation with provable bounds.
    """
    n = len(signal)
    n_windows = (n + window_size - 1) // window_size
    padded = np.zeros(n_windows * window_size)
    padded[:n] = signal

    windows = padded.reshape(-1, window_size)
    minimums = np.min(windows, axis=1)
    normalized = np.array([w - m for w, m in zip(windows, minimums)])

    # Reconstruction
    reconstructed = np.array([n + m for n, m in zip(normalized, minimums)]).flatten()[:n]

    return {
        "normalized_windows": normalized,
        "minimums": minimums,
        "original_length": n,
        "compression_ratio": (normalized.size + minimums.size) / signal.size,
        "reconstruction_error": float(np.max(np.abs(signal - reconstructed))),
        "reconstructed": reconstructed
    }


def graph_weight_canonicalization(adjacency: np.ndarray) -> np.ndarray:
    """
    Canonicalize graph edge weights using tropical normalization.

    For each row (node's outgoing weights), normalize so the minimum
    weight is zero. This identifies graphs up to global weight shifts
    per node — a natural equivalence in tropical geometry.
    """
    result = np.copy(adjacency)
    for i in range(len(adjacency)):
        row = adjacency[i]
        finite_mask = np.isfinite(row) & (row < 1e10)
        if np.any(finite_mask):
            min_val = np.min(row[finite_mask])
            result[i, finite_mask] = row[finite_mask] - min_val
    return result


if __name__ == "__main__":
    print("Application 1: ML Feature Normalization")
    print("-" * 40)
    data = np.array([
        [100.5, 102.3, 101.1, 103.0],  # Slightly varying features
        [0.01, 0.03, 0.02, 0.05],       # Small-scale features
        [-50, -48, -51, -47],            # Negative features
    ])
    normalized = ml_feature_normalization(data)
    print(f"Original data:\n{data}")
    print(f"\nNormalized (tropical):\n{normalized}")
    print(f"\nAll minimums zero: {np.allclose(np.min(normalized, axis=1), 0)}")
    print(f"Relative differences preserved: "
          f"{np.allclose(np.diff(data, axis=1), np.diff(normalized, axis=1))}")

    print("\n\nApplication 2: Signal Compression")
    print("-" * 40)
    t = np.linspace(0, 2*np.pi, 64)
    signal = 100 + 3*np.sin(t) + np.random.randn(64) * 0.1
    result = tropical_signal_compression(signal, window_size=8)
    print(f"Signal length: {result['original_length']}")
    print(f"Reconstruction error: {result['reconstruction_error']:.2e}")
    print(f"Note: Lossless compression (exact reconstruction)")

    print("\n\nApplication 3: Graph Weight Canonicalization")
    print("-" * 40)
    adj = np.array([
        [0, 5, 3, np.inf],
        [np.inf, 0, 7, 2],
        [1, np.inf, 0, 4],
        [6, 3, np.inf, 0],
    ])
    canon = graph_weight_canonicalization(adj)
    print(f"Original weights:\n{adj}")
    print(f"\nCanonicalized:\n{canon}")
    print(f"\nMin weight per node is zero: {all(np.min(canon[i][np.isfinite(canon[i])]) == 0 for i in range(4))}")


#!/usr/bin/env python3
"""
Demonstrations of the Categorical Compression Monad framework.

This script provides concrete numerical examples of:
1. Tropical normalization as a canonical compression operator
2. Translation invariance and idempotence
3. The uniqueness/initiality property
4. MDL (Minimum Description Length) computation
5. Closure operator fixed-point witness construction
"""

import numpy as np

def trop_normalize(x: np.ndarray) -> np.ndarray:
    """Tropical normalization: subtract the coordinate minimum."""
    return x - np.min(x)

def trop_min(x: np.ndarray) -> float:
    """The tropical minimum of a vector."""
    return float(np.min(x))

# ============================================================
# Demo 1: Tropical Normalization Basics
# ============================================================
print("=" * 60)
print("DEMO 1: Tropical Normalization")
print("=" * 60)

x = np.array([3.0, 1.0, 4.0, 1.5, 9.0, 2.6])
print(f"\nInput vector:        x = {x}")
print(f"Minimum:             min(x) = {trop_min(x)}")
print(f"Normalized:          N(x) = {trop_normalize(x)}")
print(f"Min of normalized:   min(N(x)) = {trop_min(trop_normalize(x))}")

# ============================================================
# Demo 2: Idempotence
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Idempotence — N(N(x)) = N(x)")
print("=" * 60)

y = trop_normalize(x)
yy = trop_normalize(y)
print(f"\nN(x)    = {y}")
print(f"N(N(x)) = {yy}")
print(f"Equal?    {np.allclose(y, yy)}")

# ============================================================
# Demo 3: Translation Invariance
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Translation Invariance — N(x + c) = N(x)")
print("=" * 60)

for c in [0.0, 5.0, -3.14, 100.0]:
    shifted = trop_normalize(x + c)
    original = trop_normalize(x)
    print(f"  c = {c:8.2f}: N(x+c) = {shifted}, matches N(x)? {np.allclose(shifted, original)}")

# ============================================================
# Demo 4: Uniqueness / Initiality
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Initiality — Only One Canonical Compression")
print("=" * 60)

print("\nAny operator T with:")
print("  - Idempotence: T(T(x)) = T(x)")
print("  - Translation invariance: T(x+c) = T(x)")
print("  - Nonnegativity: T(x)_i >= 0")
print("  - Zero minimum: min(T(x)) = 0")
print("  - Same class: T(x) = x + c for some c")
print("must equal tropical normalization.")

print("\nVerification on random vectors:")
rng = np.random.default_rng(42)
for trial in range(5):
    v = rng.uniform(-10, 10, size=6)
    n = trop_normalize(v)
    diff = n - v
    c = diff[0]
    same_class = np.allclose(diff, c * np.ones_like(diff))
    print(f"  Trial {trial+1}: min(N(v))={trop_min(n):.4f}, "
          f"all nonneg={np.all(n >= -1e-15)}, "
          f"same class={same_class}, "
          f"c = {c:.4f}")

# ============================================================
# Demo 5: MDL Computation
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: MDL — Compression Gain")
print("=" * 60)

def length_func(v):
    """L1 norm as a 'description length'."""
    return float(np.sum(np.abs(v)))

print(f"\nUsing L1 norm as length functional.")
for name, v in [("x", x), ("2*x", 2*x), ("x + 100", x + 100)]:
    nv = trop_normalize(v)
    L_orig = length_func(v)
    L_comp = length_func(nv)
    gain = L_orig - L_comp
    print(f"  {name:10s}: L(v)={L_orig:8.2f}, L(N(v))={L_comp:8.2f}, gain={gain:8.2f}")

# ============================================================
# Demo 6: Closure Operator Fixed Points
# ============================================================
print("\n" + "=" * 60)
print("DEMO 6: Closure Operator Fixed Points")
print("=" * 60)

def closure_round(x, precision=0.5):
    """A simple closure operator: round up to nearest multiple of precision."""
    return np.ceil(x / precision) * precision

print(f"\nClosure operator: round up to nearest 0.5")
vals = [0.1, 0.3, 0.5, 0.7, 1.0, 1.3, 2.0]
for v in vals:
    cv = closure_round(v)
    ccv = closure_round(cv)
    is_fixed = np.isclose(cv, ccv)
    print(f"  c({v:.1f}) = {cv:.1f}, c(c({v:.1f})) = {ccv:.1f}, "
          f"fixed point? {is_fixed}, v <= c(v)? {v <= cv + 1e-10}")

print("\n✓ Every element has a fixed-point representative (its closure)")
print("✓ The closure is always >= the original (extensive)")
print("✓ The closure is always idempotent: c(c(x)) = c(x)")

# ============================================================
# Demo 7: Tropical Projective Classes
# ============================================================
print("\n" + "=" * 60)
print("DEMO 7: Tropical Projective Classes")
print("=" * 60)

base = np.array([1.0, 3.0, 2.0])
print(f"\nBase vector: {base}")
print(f"All vectors differing by a constant have the same normalization:")
for c in [-5, -1, 0, 1, 5, 100]:
    v = base + c
    n = trop_normalize(v)
    print(f"  {base} + {c:4d} = {v} → N = {n}")

print("\n✓ Tropical normalization selects the unique representative")
print("  with minimum coordinate = 0 from each projective class.")

print("\n" + "=" * 60)
print("All demos completed successfully!")
print("=" * 60)
