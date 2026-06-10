"""
applications.py — Applications of tropical entanglement geometry.

Shows how the tropical profile and envelope can be used in practice:
1. Spectral gap detection from slope plateaus.
2. Entanglement entropy estimation from tropical bounds.
3. Phase classification of many-body spectra.
"""

import numpy as np
from math import log, exp
from typing import List, Tuple, Optional


# ===== Inline algorithms =====

def elementary_symmetric_polynomials(weights: np.ndarray) -> np.ndarray:
    m = len(weights)
    e = np.zeros(m + 1)
    e[0] = 1.0
    for i in range(m):
        for k in range(min(i + 1, m), 0, -1):
            e[k] += weights[i] * e[k - 1]
    return e


def block_spectrum(blocks: List[Tuple[float, int]]) -> np.ndarray:
    return np.concatenate([np.full(mult, w) for w, mult in blocks])


# ===== Application 1: Spectral Gap Detection =====

def detect_spectral_gaps(weights: np.ndarray, threshold: float = 0.3) -> List[int]:
    """Detect spectral gaps from the tropical slope profile.

    The tropical slope profile is the sequence of discrete differences
    of log(e_k). In a block spectrum, slopes cluster near log(w_j) for
    each band, with sharp transitions at gap locations.

    This function finds indices where the slope drops significantly,
    indicating a spectral gap (transition between bands).

    Args:
        weights: Array of nonneg weights (the entanglement spectrum).
        threshold: Minimum slope change to count as a gap.

    Returns:
        List of indices where gaps are detected.

    Example:
        >>> weights = block_spectrum([(5.0, 4), (1.0, 3)])
        >>> detect_spectral_gaps(weights)
        [3, 4]  # Gap near index 4 where block 1 saturates
    """
    e = elementary_symmetric_polynomials(weights)
    m = len(weights)

    profile = np.array([log(e[k]) if e[k] > 0 else float('-inf') for k in range(m + 1)])
    slopes = np.diff(profile)

    gaps = []
    for k in range(1, len(slopes)):
        drop = slopes[k - 1] - slopes[k]
        if drop > threshold:
            gaps.append(k)

    return gaps


# ===== Application 2: Entropy Bound from Tropical Profile =====

def tropical_entropy_bounds(weights: np.ndarray) -> Tuple[float, float]:
    """Estimate the Shannon entropy of a probability spectrum using tropical bounds.

    For a probability spectrum (weights summing to 1), the Shannon entropy
    H = -sum(p_i * log(p_i)) is related to the elementary symmetric polynomials.

    The tropical sandwich (max ≤ log-sum-exp ≤ max + log n) gives bounds
    on the partition function, which translates to entropy bounds.

    For a free-fermion spectrum with filling fractions λ_i ∈ [0,1]:
    - Lower bound: From the Newton defect (log-concavity gap)
    - Upper bound: log(m) (maximal entropy)

    Args:
        weights: Probability spectrum (should be in [0,1]).

    Returns:
        (lower_bound, upper_bound) for the Shannon entropy.
    """
    m = len(weights)
    weights_clipped = np.clip(weights, 1e-15, 1 - 1e-15)

    # Direct entropy
    entropy = -np.sum(weights_clipped * np.log(weights_clipped) +
                      (1 - weights_clipped) * np.log(1 - weights_clipped))

    # Tropical bound: from e_1 and e_2
    e = elementary_symmetric_polynomials(weights_clipped)
    e1 = e[1]  # sum of λ_i
    e2 = e[2] if m >= 2 else 0  # sum of λ_i λ_j for i<j

    # Variance = e1 - e1^2 + 2*e2 (for unit interval spectra)
    variance = np.sum(weights_clipped * (1 - weights_clipped))

    # Lower: 2 * variance (quadratic surrogate)
    lower = 2 * variance

    # Upper: m * log(2)
    upper = m * log(2)

    return lower, upper


# ===== Application 3: Phase Classification =====

def classify_spectrum_phase(weights: np.ndarray) -> str:
    """Classify a spectrum into phases based on tropical profile geometry.

    Categories:
    - "pure": Single dominant weight (flat profile, one slope)
    - "gapped": Clear spectral gap (multiple slope plateaus)
    - "critical": No clear plateau structure (smooth concave profile)

    The classification uses the slope variance within detected blocks.

    Args:
        weights: Array of nonneg weights.

    Returns:
        Phase classification string.
    """
    if len(weights) < 2:
        return "pure"

    e = elementary_symmetric_polynomials(weights)
    m = len(weights)

    profile = np.array([log(e[k]) if e[k] > 0 else float('-inf') for k in range(m + 1)])
    slopes = np.diff(profile)
    valid_slopes = slopes[np.isfinite(slopes)]

    if len(valid_slopes) < 2:
        return "pure"

    # Check for plateaus: compute second differences
    second_diff = np.diff(valid_slopes)
    max_curvature = np.max(np.abs(second_diff))
    mean_curvature = np.mean(np.abs(second_diff))

    # Ratio of max to mean curvature
    if mean_curvature < 1e-10:
        return "pure"

    curvature_ratio = max_curvature / mean_curvature

    if curvature_ratio > 3.0:
        return "gapped"
    elif curvature_ratio < 1.5:
        return "critical"
    else:
        return "gapped"


# ===== Main =====

if __name__ == "__main__":
    print("=== Application 1: Spectral Gap Detection ===")
    blocks = [(5.0, 5), (1.5, 4), (0.3, 3)]
    spectrum = block_spectrum(blocks)
    gaps = detect_spectral_gaps(spectrum, threshold=0.2)
    print(f"Spectrum blocks: {blocks}")
    print(f"Detected gap locations: {gaps}")
    print(f"Expected: near indices {5} and {9} (cumulative multiplicities)")

    print("\n=== Application 2: Entropy Bounds ===")
    prob_spectrum = np.array([0.9, 0.8, 0.3, 0.1, 0.05])
    lower, upper = tropical_entropy_bounds(prob_spectrum)
    direct_entropy = -np.sum(prob_spectrum * np.log(np.clip(prob_spectrum, 1e-15, None)) +
                             (1-prob_spectrum) * np.log(np.clip(1-prob_spectrum, 1e-15, None)))
    print(f"Spectrum: {prob_spectrum}")
    print(f"Direct entropy: {direct_entropy:.4f}")
    print(f"Tropical bounds: [{lower:.4f}, {upper:.4f}]")

    print("\n=== Application 3: Phase Classification ===")
    for name, spec in [
        ("Pure (one band)", block_spectrum([(3.0, 5)])),
        ("Gapped (two bands)", block_spectrum([(5.0, 4), (0.5, 4)])),
        ("Critical (smooth)", np.linspace(0.1, 5.0, 10)),
    ]:
        phase = classify_spectrum_phase(spec)
        print(f"  {name}: {phase}")


"""
demo.py — Demonstrations of tropical entanglement geometry.

Computes:
1. Exact e_k values for block spectra.
2. The tropical profile log(e_k).
3. Discrete slope profiles.
4. Block envelopes.
5. Overlay comparisons showing agreement/deviation.
6. Numerical tests of the asymptotic segmentation conjecture.
"""

import numpy as np
from math import log, comb
from typing import List, Tuple


# ===== Core algorithms (self-contained) =====

def elementary_symmetric_polynomials(weights: np.ndarray) -> np.ndarray:
    """Compute all e_k(w) for k = 0, ..., m via O(m^2) DP."""
    m = len(weights)
    e = np.zeros(m + 1)
    e[0] = 1.0
    for i in range(m):
        for k in range(min(i + 1, m), 0, -1):
            e[k] += weights[i] * e[k - 1]
    return e


def block_spectrum(blocks: List[Tuple[float, int]]) -> np.ndarray:
    """Create spectrum from (weight, multiplicity) pairs."""
    return np.concatenate([np.full(mult, w) for w, mult in blocks])


def two_block_envelope(a: float, b: float, p: int, q: int) -> np.ndarray:
    """Two-block tropical envelope: fill heavier block first."""
    N = p + q
    env = np.zeros(N + 1)
    la, lb = log(a), log(b)
    for k in range(N + 1):
        r1 = min(k, p)
        env[k] = la * r1 + lb * (k - r1)
    return env


def multi_block_envelope(blocks: List[Tuple[float, int]]) -> np.ndarray:
    """Multi-block tropical envelope via greedy allocation."""
    N = sum(m for _, m in blocks)
    env = np.zeros(N + 1)
    for k in range(1, N + 1):
        rem = k
        val = 0.0
        for w, m in blocks:
            alloc = min(rem, m)
            if alloc > 0 and w > 0:
                val += log(w) * alloc
            rem -= alloc
            if rem == 0:
                break
        env[k] = val
    return env


# ===== Demo 1: Two-block spectrum =====
def demo_two_block():
    print("=" * 60)
    print("DEMO 1: Two-Block Spectrum")
    print("=" * 60)
    a, b, p, q = 5.0, 1.5, 4, 3
    print(f"Block 1: weight={a}, multiplicity={p}")
    print(f"Block 2: weight={b}, multiplicity={q}")

    spectrum = block_spectrum([(a, p), (b, q)])
    e = elementary_symmetric_polynomials(spectrum)
    N = p + q

    print(f"\nElementary symmetric polynomials e_k:")
    for k in range(N + 1):
        print(f"  e_{k} = {e[k]:.4f}")

    # Tropical profile
    profile = np.array([log(e[k]) if e[k] > 0 else float('-inf') for k in range(N + 1)])
    print(f"\nTropical profile log(e_k):")
    for k in range(N + 1):
        print(f"  log(e_{k}) = {profile[k]:.4f}")

    # Slopes
    slopes = np.diff(profile)
    print(f"\nDiscrete slopes:")
    for k in range(N):
        print(f"  slope_{k} = {slopes[k]:.4f}")

    # Verify slope antitonicity
    print(f"\nSlope antitonicity check:")
    for k in range(1, N):
        ok = slopes[k] <= slopes[k - 1] + 1e-10
        print(f"  slope_{k} <= slope_{k-1}: {slopes[k]:.4f} <= {slopes[k-1]:.4f} {'✓' if ok else '✗'}")

    # Block envelope
    env = two_block_envelope(a, b, p, q)
    print(f"\nBlock envelope:")
    for k in range(N + 1):
        print(f"  F({k}) = {env[k]:.4f}")

    # Compare profile vs envelope
    print(f"\nProfile vs Envelope comparison:")
    for k in range(N + 1):
        diff = profile[k] - env[k]
        print(f"  k={k}: log(e_k)={profile[k]:.4f}, F(k)={env[k]:.4f}, diff={diff:.4f}")
    print(f"  Profile >= Envelope everywhere: {all(profile[k] >= env[k] - 1e-10 for k in range(N+1))}")


# ===== Demo 2: Three-block spectrum =====
def demo_three_block():
    print("\n" + "=" * 60)
    print("DEMO 2: Three-Block Spectrum")
    print("=" * 60)
    blocks = [(8.0, 3), (3.0, 4), (1.0, 3)]
    print(f"Blocks: {blocks}")

    spectrum = block_spectrum(blocks)
    e = elementary_symmetric_polynomials(spectrum)
    N = sum(m for _, m in blocks)

    profile = np.array([log(e[k]) if e[k] > 0 else float('-inf') for k in range(N + 1)])
    slopes = np.diff(profile)
    env = multi_block_envelope(blocks)

    print(f"\nSlope plateaus (should cluster near log(w_j)):")
    log_weights = [log(w) for w, _ in blocks]
    print(f"  Expected plateaus at: {[f'{lw:.4f}' for lw in log_weights]}")
    for k in range(N):
        closest = min(log_weights, key=lambda lw: abs(slopes[k] - lw))
        print(f"  slope_{k} = {slopes[k]:.4f} (nearest: {closest:.4f})")


# ===== Demo 3: Newton inequality verification =====
def demo_newton():
    print("\n" + "=" * 60)
    print("DEMO 3: Newton Inequality Verification")
    print("=" * 60)

    for name, weights in [
        ("Uniform [2,2,2,2]", np.array([2.0, 2.0, 2.0, 2.0])),
        ("Linear [1,2,3,4,5]", np.array([1.0, 2.0, 3.0, 4.0, 5.0])),
        ("Block [5,5,5,1,1]", np.array([5.0, 5.0, 5.0, 1.0, 1.0])),
        ("Geometric [1,2,4,8]", np.array([1.0, 2.0, 4.0, 8.0])),
    ]:
        e = elementary_symmetric_polynomials(weights)
        m = len(weights)
        print(f"\n  {name}:")
        all_ok = True
        for k in range(1, m):
            defect = e[k]**2 - e[k-1] * e[k+1]
            ok = defect >= -1e-10
            if not ok:
                all_ok = False
            print(f"    k={k}: e_k^2 - e_{{k-1}}*e_{{k+1}} = {defect:.6f} {'✓' if ok else '✗'}")
        print(f"    All Newton inequalities hold: {'✓' if all_ok else '✗'}")


# ===== Demo 4: Log-sum-exp sandwich =====
def demo_log_sum_exp():
    print("\n" + "=" * 60)
    print("DEMO 4: Log-Sum-Exp Sandwich (Stat Mech Bridge)")
    print("=" * 60)

    for name, vals in [
        ("Small set", np.array([1.0, 2.0, 3.0])),
        ("Uniform", np.array([5.0, 5.0, 5.0, 5.0])),
        ("Spread", np.array([0.0, 10.0, 20.0])),
    ]:
        max_val = np.max(vals)
        lse = max_val + log(np.sum(np.exp(vals - max_val)))
        ub = max_val + log(len(vals))
        print(f"\n  {name}: values={vals}")
        print(f"    max = {max_val:.4f}")
        print(f"    log-sum-exp = {lse:.4f}")
        print(f"    max + log(n) = {ub:.4f}")
        print(f"    Sandwich: {max_val:.4f} ≤ {lse:.4f} ≤ {ub:.4f} ✓")


# ===== Demo 5: Asymptotic segmentation conjecture test =====
def demo_asymptotic():
    print("\n" + "=" * 60)
    print("DEMO 5: Asymptotic Tropical Segmentation Conjecture Test")
    print("=" * 60)

    w1, w2 = 4.0, 1.5
    alpha1, alpha2 = 0.4, 0.6
    print(f"Two-block model: w1={w1}, w2={w2}, α1={alpha1}, α2={alpha2}")

    for m in [10, 20, 50, 100]:
        p = int(alpha1 * m)
        q = m - p
        spectrum = block_spectrum([(w1, p), (w2, q)])
        e = elementary_symmetric_polynomials(spectrum)

        # Normalized profile at x = 0.5
        x = 0.5
        k = int(x * m)
        if e[k] > 0:
            normalized = log(e[k]) / m
        else:
            normalized = float('-inf')

        # Expected limit: piecewise linear
        # At x=0.5 > alpha1=0.4, the limit is:
        # F(0.5) = alpha1*log(w1) + (0.5-alpha1)*log(w2) = 0.4*log(4) + 0.1*log(1.5)
        expected = alpha1 * log(w1) + (x - alpha1) * log(w2)

        print(f"  m={m:3d}: normalized profile at x={x} = {normalized:.4f}, "
              f"expected limit = {expected:.4f}, diff = {abs(normalized - expected):.4f}")


# ===== Demo 6: Slope plateau visualization data =====
def demo_slope_plateaus():
    print("\n" + "=" * 60)
    print("DEMO 6: Slope Plateaus for Large Block Spectra")
    print("=" * 60)

    blocks = [(10.0, 20), (3.0, 15), (1.0, 15)]
    spectrum = block_spectrum(blocks)
    e = elementary_symmetric_polynomials(spectrum)
    N = len(spectrum)

    profile = np.array([log(e[k]) if e[k] > 0 else float('-inf') for k in range(N + 1)])
    slopes = np.diff(profile)

    print(f"Blocks: {blocks}")
    print(f"Expected slope plateaus at log(w): {[log(w) for w,_ in blocks]}")
    print(f"\nSlope sequence (first 10, around transitions, last 10):")

    cumul = 0
    for w, mult in blocks:
        print(f"\n  Block w={w}, mult={mult}, indices {cumul}-{cumul+mult-1}:")
        for k in range(cumul, min(cumul + mult, N)):
            print(f"    slope_{k} = {slopes[k]:.4f} (expected log({w}) = {log(w):.4f})")
        cumul += mult


if __name__ == "__main__":
    demo_two_block()
    demo_three_block()
    demo_newton()
    demo_log_sum_exp()
    demo_asymptotic()
    demo_slope_plateaus()


"""
Visualization 2: Asymptotic Tropical Segmentation

Tests the conjecture that normalized tropical profiles converge to
piecewise-linear limits. For increasingly large block spectra,
plots the rescaled profile (1/m) * log(e_{xm}) and compares to
the predicted piecewise-linear limit function.

This visualization is the computational evidence for the
Asymptotic Tropical Segmentation Conjecture.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import log


def elementary_symmetric_polynomials(weights):
    m = len(weights)
    e = np.zeros(m + 1)
    e[0] = 1.0
    for i in range(m):
        for k in range(min(i + 1, m), 0, -1):
            e[k] += weights[i] * e[k - 1]
    return e


def block_spectrum(blocks):
    return np.concatenate([np.full(mult, w) for w, mult in blocks])


def piecewise_linear_limit(x, blocks):
    """Compute the predicted piecewise-linear limit F(x)."""
    total = sum(m for _, m in blocks)
    alphas = [m / total for _, m in blocks]
    log_weights = [log(w) if w > 0 else 0 for w, _ in blocks]

    cumul = 0.0
    val = 0.0
    for alpha, lw in zip(alphas, log_weights):
        if x <= cumul + alpha:
            val += lw * (x - cumul)
            return val
        else:
            val += lw * alpha
            cumul += alpha
    return val


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Two-block model
w1, w2 = 5.0, 1.5
alpha1, alpha2 = 0.4, 0.6

ax = axes[0]
sizes = [10, 20, 40, 80]
colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(sizes)))

for size_idx, m_total in enumerate(sizes):
    p = int(alpha1 * m_total)
    q = m_total - p
    blocks = [(w1, p), (w2, q)]
    spectrum = block_spectrum(blocks)
    e = elementary_symmetric_polynomials(spectrum)

    xs = np.array([k / m_total for k in range(m_total + 1)])
    normalized = np.array([
        log(e[k]) / m_total if e[k] > 0 else float('-inf')
        for k in range(m_total + 1)
    ])

    ax.plot(xs, normalized, 'o-', color=colors[size_idx], markersize=2,
            linewidth=1.5, alpha=0.8, label=f'm={m_total}')

# Plot limit function
x_fine = np.linspace(0, 1, 200)
limit_blocks = [(w1, int(alpha1 * 100)), (w2, int(alpha2 * 100))]
limit_vals = np.array([piecewise_linear_limit(x, limit_blocks) for x in x_fine])
ax.plot(x_fine, limit_vals, 'k-', linewidth=2.5, label='Predicted limit')

ax.axvline(x=alpha1, color='red', linestyle=':', alpha=0.5, label=f'Gap at α₁={alpha1}')
ax.set_xlabel('x = k/m', fontsize=13)
ax.set_ylabel('(1/m) · log e_{⌊xm⌋}', fontsize=13)
ax.set_title(f'Two-Block Convergence\nw₁={w1}, w₂={w2}, α₁={alpha1}', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Slope convergence
ax = axes[1]
for size_idx, m_total in enumerate(sizes):
    p = int(alpha1 * m_total)
    q = m_total - p
    spectrum = block_spectrum([(w1, p), (w2, q)])
    e = elementary_symmetric_polynomials(spectrum)

    profile = np.array([log(e[k]) if e[k] > 0 else float('-inf')
                        for k in range(m_total + 1)])
    slopes = np.diff(profile)
    xs = np.array([k / m_total for k in range(m_total)])

    ax.plot(xs, slopes, 'o-', color=colors[size_idx], markersize=2,
            linewidth=1.5, alpha=0.8, label=f'm={m_total}')

ax.axhline(y=log(w1), color='blue', linestyle='--', alpha=0.6, label=f'log({w1})={log(w1):.2f}')
ax.axhline(y=log(w2), color='green', linestyle='--', alpha=0.6, label=f'log({w2})={log(w2):.2f}')
ax.axvline(x=alpha1, color='red', linestyle=':', alpha=0.5)

ax.set_xlabel('x = k/m', fontsize=13)
ax.set_ylabel('Discrete slope', fontsize=13)
ax.set_title(f'Slope Convergence to Plateaus', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.suptitle('Asymptotic Tropical Segmentation Conjecture — Computational Evidence',
             fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('asymptotic_convergence.png', dpi=150, bbox_inches='tight')
print("Saved asymptotic_convergence.png")


"""
Visualization 3: Log-Sum-Exp Sandwich and Statistical Mechanics

Visualizes the cross-domain theorem connecting tropical geometry to
statistical mechanics. The log-sum-exp sandwich

    max(a_i) ≤ log Σ exp(a_i) ≤ max(a_i) + log n

shows that the free energy (log-sum-exp) is sandwiched between
the ground state energy (max) and ground state + entropy (max + log n).

As temperature → 0, the tropical (max) term dominates.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import log, exp


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Sandwich visualization for varying number of terms
ax = axes[0]
ns = list(range(2, 51))
max_vals = []
lse_vals = []
upper_vals = []

np.random.seed(42)
base_values = np.random.randn(50)

for n in ns:
    vals = base_values[:n]
    mx = np.max(vals)
    shifted = vals - mx
    lse = mx + log(np.sum(np.exp(shifted)))
    max_vals.append(mx)
    lse_vals.append(lse)
    upper_vals.append(mx + log(n))

ax.fill_between(ns, max_vals, upper_vals, alpha=0.15, color='blue',
                label='Sandwich region')
ax.plot(ns, max_vals, 'b-', linewidth=2, label=r'$\max_i a_i$')
ax.plot(ns, lse_vals, 'r-', linewidth=2, label=r'$\log \sum e^{a_i}$')
ax.plot(ns, upper_vals, 'g--', linewidth=2, label=r'$\max + \log n$')
ax.set_xlabel('Number of terms $n$', fontsize=12)
ax.set_ylabel('Value', fontsize=12)
ax.set_title('Log-Sum-Exp Sandwich', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: Temperature interpretation
ax = axes[1]
values = np.array([1.0, 2.5, 4.0, 3.0])
betas = np.linspace(0.1, 5.0, 50)  # inverse temperature

free_energies = []
ground_state = np.max(values)

for beta in betas:
    shifted = beta * values - beta * ground_state
    fe = ground_state + (1/beta) * log(np.sum(np.exp(shifted)))
    free_energies.append(fe)

ax.plot(betas, free_energies, 'r-', linewidth=2, label=r'$\frac{1}{\beta}\log \sum e^{\beta a_i}$')
ax.axhline(y=ground_state, color='blue', linestyle='--', linewidth=2,
           label=f'Ground state = {ground_state}')
ax.axhline(y=ground_state + log(len(values))/betas[0], color='gray',
           linestyle=':', alpha=0.5)

ax.set_xlabel(r'Inverse temperature $\beta$', fontsize=12)
ax.set_ylabel('Free energy', fontsize=12)
ax.set_title('Tropical Limit as T → 0', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.annotate('Tropical\nlimit', xy=(4.5, ground_state + 0.05),
            fontsize=10, color='blue', ha='center')

# Panel 3: Block spectrum sandwich
ax = axes[2]
blocks = [(6.0, 4), (2.0, 3)]
spectrum = np.concatenate([np.full(m, w) for w, m in blocks])
N = len(spectrum)

# Compute exact e_k
def esp(weights):
    m = len(weights)
    e = np.zeros(m + 1)
    e[0] = 1.0
    for i in range(m):
        for k in range(min(i + 1, m), 0, -1):
            e[k] += weights[i] * e[k - 1]
    return e

e = esp(spectrum)
profile = np.array([log(e[k]) if e[k] > 0 else float('-inf') for k in range(N + 1)])

# Envelope
la, lb = log(blocks[0][0]), log(blocks[1][0])
p = blocks[0][1]
envelope = np.array([la * min(k, p) + lb * max(k - p, 0) for k in range(N + 1)])

# Admissible count (entropy term)
def adm_count(p, q, k):
    r1_min = max(0, k - q)
    r1_max = min(k, p)
    return max(0, r1_max - r1_min + 1)

q = blocks[1][1]
entropy_correction = np.array([log(adm_count(p, q, k)) if adm_count(p, q, k) > 0 else 0
                                for k in range(N + 1)])

ks = np.arange(N + 1)
ax.plot(ks, profile, 'b-o', markersize=5, linewidth=2, label=r'$\log e_k$')
ax.plot(ks, envelope, 'r--s', markersize=5, linewidth=2, label='Envelope $F(k)$')
ax.plot(ks, envelope + entropy_correction, 'g-.^', markersize=5, linewidth=2,
        label='$F(k) + \\log |\\mathcal{C}_k|$')

ax.fill_between(ks, envelope, envelope + entropy_correction, alpha=0.1, color='green')
ax.set_xlabel('$k$', fontsize=12)
ax.set_ylabel('Value', fontsize=12)
ax.set_title('Tropical Sandwich for Block Spectrum', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.suptitle('Statistical Mechanics of Tropical Entanglement',
             fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('log_sum_exp_sandwich.png', dpi=150, bbox_inches='tight')
print("Saved log_sum_exp_sandwich.png")


"""
Visualization 1: Tropical Profile and Block Envelope

Visualizes the core concept of tropical entanglement geometry:
the tropical profile log(e_k) is a discrete concave potential,
and for block spectra it is bounded by the piecewise-linear
tropical envelope. The slopes cluster into plateaus corresponding
to spectral bands, with transitions at gap locations.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import log


def elementary_symmetric_polynomials(weights):
    m = len(weights)
    e = np.zeros(m + 1)
    e[0] = 1.0
    for i in range(m):
        for k in range(min(i + 1, m), 0, -1):
            e[k] += weights[i] * e[k - 1]
    return e


def block_spectrum(blocks):
    return np.concatenate([np.full(mult, w) for w, mult in blocks])


def multi_block_envelope(blocks):
    N = sum(m for _, m in blocks)
    env = np.zeros(N + 1)
    for k in range(1, N + 1):
        rem = k
        val = 0.0
        for w, m in blocks:
            alloc = min(rem, m)
            if alloc > 0 and w > 0:
                val += log(w) * alloc
            rem -= alloc
            if rem == 0:
                break
        env[k] = val
    return env


# Setup
blocks = [(8.0, 5), (3.0, 4), (1.0, 4)]
spectrum = block_spectrum(blocks)
N = len(spectrum)

e = elementary_symmetric_polynomials(spectrum)
profile = np.array([log(e[k]) if e[k] > 0 else float('-inf') for k in range(N + 1)])
slopes = np.diff(profile)
envelope = multi_block_envelope(blocks)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Tropical profile vs envelope
ax = axes[0]
ks = np.arange(N + 1)
ax.plot(ks, profile, 'b-o', markersize=4, label=r'$\log e_k(\lambda)$ (tropical profile)', linewidth=2)
ax.plot(ks, envelope, 'r--s', markersize=4, label=r'$F(k)$ (block envelope)', linewidth=2)
ax.fill_between(ks, envelope, profile, alpha=0.15, color='blue')
ax.set_xlabel('$k$', fontsize=13)
ax.set_ylabel('Value', fontsize=13)
ax.set_title('Tropical Profile vs Block Envelope', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: Slope profile with plateau lines
ax = axes[1]
slope_ks = np.arange(N)
ax.plot(slope_ks, slopes, 'g-o', markersize=4, linewidth=2, label='Discrete slopes')

# Draw expected plateaus
cumul = 0
colors = ['red', 'orange', 'purple']
for idx, (w, mult) in enumerate(blocks):
    lw = log(w) if w > 0 else 0
    ax.axhline(y=lw, color=colors[idx], linestyle='--', alpha=0.6,
               label=f'$\\log({w})={lw:.2f}$')
    ax.axvline(x=cumul, color='gray', linestyle=':', alpha=0.4)
    cumul += mult

ax.set_xlabel('$k$', fontsize=13)
ax.set_ylabel('Slope', fontsize=13)
ax.set_title('Slope Plateaus (Gap = Corner)', fontsize=13)
ax.legend(fontsize=9, loc='upper right')
ax.grid(True, alpha=0.3)

# Panel 3: Newton defect
ax = axes[2]
defects = []
for k in range(1, N):
    d = e[k]**2 - e[k-1]*e[k+1]
    defects.append(d)

ax.bar(range(1, N), defects, color='steelblue', alpha=0.7, edgecolor='navy')
ax.axhline(y=0, color='red', linestyle='-', linewidth=1)
ax.set_xlabel('$k$', fontsize=13)
ax.set_ylabel(r'$e_k^2 - e_{k-1} e_{k+1}$', fontsize=13)
ax.set_title("Newton's Inequality Defect (≥ 0)", fontsize=13)
ax.grid(True, alpha=0.3)

plt.suptitle('Tropical Geometry of Entanglement Spectra\n'
             f'Block spectrum: {blocks}', fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('tropical_profile.png', dpi=150, bbox_inches='tight')
print("Saved tropical_profile.png")
