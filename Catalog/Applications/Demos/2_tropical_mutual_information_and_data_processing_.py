#!/usr/bin/env python3
"""
Tropical Mutual Information — Real-World Applications

Demonstrates how tropical MI and the DPI apply to:
1. Cryptographic key exchange leakage analysis
2. Privacy amplification through hashing
3. Neural network information bottleneck
4. Tropical orbit compression in post-quantum protocols
"""

import numpy as np
from typing import List, Tuple


# ─── Core functions (self-contained) ─────────────────────────────

def tropical_mi(pXY: np.ndarray) -> float:
    pX = pXY.sum(axis=1)
    v_x = float(np.max(pX))
    v_xy = float(np.sum(np.max(pXY, axis=0)))
    return -np.log2(v_x) + np.log2(v_xy)

def cond_vulnerability(pXY: np.ndarray) -> float:
    return float(np.sum(np.max(pXY, axis=0)))

def pushforward_snd(pXY, f, n_out):
    n_x, n_y = pXY.shape
    result = np.zeros((n_x, n_out))
    for y in range(n_y):
        result[:, f(y)] += pXY[:, y]
    return result


# ═══════════════════════════════════════════════════════════════════
# Application 1: Tropical Key Exchange Leakage Analysis
# ═══════════════════════════════════════════════════════════════════

def app_key_exchange():
    """
    Simulate a tropical key exchange and analyze information leakage.
    
    Model:
    - Secret key X ∈ {0,...,7}: 8 possible keys (3 bits)
    - Public transcript Y ∈ {0,...,15}: 16 possible messages
    - The joint distribution reflects that Y is correlated with X
      but does not uniquely determine it.
    
    Post-processings:
    - Canonical form: reduce Y to 8 canonical representatives
    - Hash: reduce Y to 4-bit hash
    - Truncation: keep only top 2 bits of Y
    """
    print("=" * 60)
    print("APPLICATION 1: Tropical Key Exchange Leakage")
    print("=" * 60)
    
    rng = np.random.default_rng(42)
    n_secret, n_transcript = 8, 16
    
    # Generate a realistic key exchange distribution
    # Each key produces a few transcripts with high probability
    pXY = np.zeros((n_secret, n_transcript))
    for x in range(n_secret):
        # Each key maps to ~3 likely transcripts
        likely = [(2*x) % n_transcript, (2*x+1) % n_transcript, (3*x+5) % n_transcript]
        for y in likely:
            pXY[x, y] += rng.exponential(0.5)
        # Small noise on all transcripts
        pXY[x, :] += rng.exponential(0.01, size=n_transcript)
    pXY /= pXY.sum()
    
    mi_original = tropical_mi(pXY)
    vuln = cond_vulnerability(pXY)
    
    print(f"Secret: {n_secret} keys ({np.log2(n_secret):.0f} bits)")
    print(f"Transcript: {n_transcript} messages")
    print(f"Leakage I∞(Key; Transcript) = {mi_original:.4f} bits")
    print(f"Adversary success prob V(Key|Transcript) = {vuln:.4f}")
    print()
    
    # Post-processings
    processings = [
        ("Canonical form (mod 8)", lambda y: y % 8, 8),
        ("4-bit hash (mod 4)", lambda y: y % 4, 4),
        ("Top 2 bits (// 4)", lambda y: y // 4, 4),
        ("Parity (mod 2)", lambda y: y % 2, 2),
        ("Constant (erase)", lambda y: 0, 1),
    ]
    
    print("Post-processing analysis (DPI guarantees I∞ can only decrease):")
    for name, f, n_out in processings:
        pXfY = pushforward_snd(pXY, f, n_out)
        mi = tropical_mi(pXfY)
        loss_pct = (mi_original - mi) / mi_original * 100 if mi_original > 0 else 0
        print(f"  {name:30s}: I∞ = {mi:.4f} bits (loss: {loss_pct:.1f}%)")
    print()


# ═══════════════════════════════════════════════════════════════════
# Application 2: Privacy Amplification via Hashing
# ═══════════════════════════════════════════════════════════════════

def app_privacy_amplification():
    """
    Show how hashing reduces leakage (privacy amplification).
    
    A user's data X has partial leakage through an observation Y.
    We apply a sequence of increasingly coarse hash functions to Y,
    measuring how leakage decreases at each step.
    """
    print("=" * 60)
    print("APPLICATION 2: Privacy Amplification via Hashing")
    print("=" * 60)
    
    rng = np.random.default_rng(123)
    n_data, n_obs = 6, 12
    
    # Create a joint distribution with moderate leakage
    pXY = np.zeros((n_data, n_obs))
    for x in range(n_data):
        for y in range(n_obs):
            if y % n_data == x:
                pXY[x, y] = 0.12
            else:
                pXY[x, y] = 0.02
    pXY += rng.exponential(0.005, size=(n_data, n_obs))
    pXY /= pXY.sum()
    
    print(f"Data space: {n_data} values")
    print(f"Observation space: {n_obs} values")
    print(f"Original leakage: I∞ = {tropical_mi(pXY):.4f} bits")
    print()
    
    # Apply hash functions of decreasing output size
    print("Hashing sequence (each step applies DPI):")
    current = pXY
    current_size = n_obs
    
    for target in [8, 6, 4, 3, 2, 1]:
        if target >= current_size:
            continue
        f = lambda y, t=target, c=current_size: y % t
        new = pushforward_snd(current, f, target)
        mi = tropical_mi(new)
        vuln = cond_vulnerability(new)
        print(f"  Hash to {target:2d} bins: I∞ = {mi:.4f} bits, "
              f"V(X|hash) = {vuln:.4f}")
        current = new
        current_size = target
    print()


# ═══════════════════════════════════════════════════════════════════
# Application 3: Neural Network Information Bottleneck
# ═══════════════════════════════════════════════════════════════════

def app_neural_network():
    """
    Model information flow through neural network layers.
    
    Each layer applies a deterministic function (ReLU + linear),
    and the DPI guarantees monotonic information decay.
    """
    print("=" * 60)
    print("APPLICATION 3: Neural Network Information Bottleneck")
    print("=" * 60)
    
    rng = np.random.default_rng(456)
    n_input = 5  # input classes
    n_features = 16  # feature dimensions
    
    # Joint distribution: input class X, feature representation Y
    pXY = np.zeros((n_input, n_features))
    for x in range(n_input):
        center = (x * n_features // n_input) + n_features // (2 * n_input)
        for y in range(n_features):
            dist = min(abs(y - center), n_features - abs(y - center))
            pXY[x, y] = np.exp(-dist * 0.5)
    pXY += rng.exponential(0.01, size=pXY.shape)
    pXY /= pXY.sum()
    
    print(f"Input classes: {n_input}")
    print(f"Initial features: {n_features}")
    
    # Simulate layers as deterministic feature reductions
    layers = [
        ("Layer 1 (16→8)", lambda y: y // 2, 8),
        ("Layer 2 (8→4)", lambda y: y // 2, 4),
        ("Layer 3 (4→2)", lambda y: y // 2, 2),
    ]
    
    current = pXY
    mi = tropical_mi(current)
    print(f"  Input layer:  I∞ = {mi:.4f} bits")
    
    for name, f, n_out in layers:
        current = pushforward_snd(current, f, n_out)
        mi = tropical_mi(current)
        print(f"  {name}: I∞ = {mi:.4f} bits")
    
    print()
    print("The DPI guarantees I∞ decreases monotonically through layers.")
    print("Information about the input class can only be lost, never created.")
    print()


# ═══════════════════════════════════════════════════════════════════
# Application 4: Tropical Orbit Compression
# ═══════════════════════════════════════════════════════════════════

def app_orbit_compression():
    """
    Model tropical orbit compression in a post-quantum protocol.
    
    Secret: tropical matrix invariant (e.g., eigenvalue signature)
    Public: orbit representative
    Compression: extract canonical invariants (traces, determinants)
    """
    print("=" * 60)
    print("APPLICATION 4: Tropical Orbit Compression")
    print("=" * 60)
    
    rng = np.random.default_rng(789)
    n_secrets = 10
    n_orbits = 20
    
    # Joint distribution: secret invariant × orbit representative
    pXY = np.zeros((n_secrets, n_orbits))
    for x in range(n_secrets):
        # Each secret maps to ~3 orbit representatives
        reps = rng.choice(n_orbits, size=3, replace=False)
        for r in reps:
            pXY[x, r] = rng.exponential(1.0)
        pXY[x, :] += rng.exponential(0.02, size=n_orbits)
    pXY /= pXY.sum()
    
    mi_full = tropical_mi(pXY)
    vuln_full = cond_vulnerability(pXY)
    
    print(f"Secret space: {n_secrets} invariants")
    print(f"Orbit space: {n_orbits} representatives")
    print(f"Full leakage: I∞ = {mi_full:.4f} bits")
    print(f"Adversary success: V = {vuln_full:.4f}")
    print()
    
    compressions = [
        ("Trace extraction (mod 10)", lambda y: y % 10, 10),
        ("Det extraction (mod 5)", lambda y: y % 5, 5),
        ("Rank extraction (mod 3)", lambda y: y % 3, 3),
    ]
    
    print("Compression analysis:")
    for name, f, n_out in compressions:
        pXfY = pushforward_snd(pXY, f, n_out)
        mi = tropical_mi(pXfY)
        vuln = cond_vulnerability(pXfY)
        print(f"  {name:30s}: I∞ = {mi:.4f} bits, V = {vuln:.4f}")
    
    print()
    print("By the DPI, ALL compressions preserve the security guarantee.")
    print("The adversary's success probability can only decrease under compression.")
    print()


# ═══════════════════════════════════════════════════════════════════
# Application 5: Multi-Round Protocol Analysis
# ═══════════════════════════════════════════════════════════════════

def app_multi_round():
    """
    Analyze leakage accumulation in a multi-round protocol.
    
    In each round, a new observation Y_i is generated and possibly
    compressed. The DPI guarantees each compression step is safe.
    """
    print("=" * 60)
    print("APPLICATION 5: Multi-Round Protocol Analysis")
    print("=" * 60)
    
    rng = np.random.default_rng(101)
    n_secret = 4
    n_obs = 8
    n_rounds = 5
    
    print(f"Protocol: {n_rounds} rounds")
    print(f"Secret space: {n_secret} values")
    print(f"Observation per round: {n_obs} values")
    print()
    
    for round_num in range(1, n_rounds + 1):
        # Generate round-specific joint distribution
        pXY = np.zeros((n_secret, n_obs))
        for x in range(n_secret):
            center = (x * n_obs // n_secret + round_num) % n_obs
            for y in range(n_obs):
                dist = abs(y - center)
                pXY[x, y] = np.exp(-dist * 0.3)
        pXY += rng.exponential(0.05, size=pXY.shape)
        pXY /= pXY.sum()
        
        mi_raw = tropical_mi(pXY)
        
        # Compress to 4 bins
        f_compress = lambda y: y % 4
        pXfY = pushforward_snd(pXY, f_compress, 4)
        mi_compressed = tropical_mi(pXfY)
        
        print(f"  Round {round_num}: I∞(raw) = {mi_raw:.4f}, "
              f"I∞(compressed) = {mi_compressed:.4f}, "
              f"DPI: {'✓' if mi_compressed <= mi_raw + 1e-10 else '✗'}")
    
    print()
    print("Each round independently satisfies the DPI.")
    print("Compression never increases the adversary's information.")
    print()


if __name__ == "__main__":
    app_key_exchange()
    app_privacy_amplification()
    app_neural_network()
    app_orbit_compression()
    app_multi_round()
    
    print("=" * 60)
    print("All applications completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Mutual Information — Demonstrations

Concrete numerical examples verifying the main theorems:
1. Nonnegativity: I∞(X;Y) ≥ 0
2. Data-Processing Inequality: I∞(X;f(Y)) ≤ I∞(X;Y)
3. Independence: I∞(X;Y) = 0 for product distributions
4. Chain-rule inequality: H∞(X,Y) ≥ H∞(X|Y)
"""

import numpy as np
from typing import Callable

# ─── Core Definitions ───────────────────────────────────────────────

def max_mass(p: np.ndarray) -> float:
    """V(X) = max_x p(x). Vulnerability / guessing probability."""
    return float(np.max(p))

def min_entropy(p: np.ndarray) -> float:
    """H∞(X) = -log2(max_x p(x)). Min-entropy in bits."""
    return -np.log2(max_mass(p))

def marginal_fst(pXY: np.ndarray) -> np.ndarray:
    """p_X(x) = ∑_y p(x,y). First marginal."""
    return pXY.sum(axis=1)

def marginal_snd(pXY: np.ndarray) -> np.ndarray:
    """p_Y(y) = ∑_x p(x,y). Second marginal."""
    return pXY.sum(axis=0)

def cond_vulnerability(pXY: np.ndarray) -> float:
    """V(X|Y) = ∑_y max_x p(x,y). Adversarial guess mass."""
    return float(np.sum(np.max(pXY, axis=0)))

def cond_min_entropy(pXY: np.ndarray) -> float:
    """H∞(X|Y) = -log2(V(X|Y)). Conditional min-entropy."""
    v = cond_vulnerability(pXY)
    if v <= 0:
        return float('inf')
    return -np.log2(v)

def tropical_mi(pXY: np.ndarray) -> float:
    """I∞(X;Y) = H∞(X) - H∞(X|Y). Tropical mutual information."""
    pX = marginal_fst(pXY)
    return min_entropy(pX) - cond_min_entropy(pXY)

def pushforward_snd(pXY: np.ndarray, f: Callable[[int], int], n_out: int) -> np.ndarray:
    """Pushforward on the second coordinate: p'(x,c) = ∑_{y:f(y)=c} p(x,y)."""
    n_x, n_y = pXY.shape
    result = np.zeros((n_x, n_out))
    for y in range(n_y):
        result[:, f(y)] += pXY[:, y]
    return result

# ─── Random distribution generators ─────────────────────────────────

def random_joint(n_x: int, n_y: int, rng=None) -> np.ndarray:
    """Generate a random joint distribution on {0,...,n_x-1} × {0,...,n_y-1}."""
    if rng is None:
        rng = np.random.default_rng()
    raw = rng.exponential(size=(n_x, n_y))
    return raw / raw.sum()

def random_product(n_x: int, n_y: int, rng=None) -> np.ndarray:
    """Generate a random product (independent) distribution."""
    if rng is None:
        rng = np.random.default_rng()
    px = rng.exponential(size=n_x)
    px /= px.sum()
    py = rng.exponential(size=n_y)
    py /= py.sum()
    return np.outer(px, py)

def random_function(n_in: int, n_out: int, rng=None) -> Callable[[int], int]:
    """Generate a random deterministic function {0,...,n_in-1} → {0,...,n_out-1}."""
    if rng is None:
        rng = np.random.default_rng()
    mapping = rng.integers(0, n_out, size=n_in)
    return lambda y: int(mapping[y])


# ─── Demonstrations ─────────────────────────────────────────────────

def demo_basic_example():
    """A concrete small example showing all quantities."""
    print("=" * 60)
    print("DEMO 1: Concrete Example")
    print("=" * 60)
    
    # Joint distribution on {0,1,2} × {0,1}
    pXY = np.array([
        [0.30, 0.05],
        [0.10, 0.25],
        [0.15, 0.15]
    ])
    
    print(f"Joint distribution p(x,y):")
    print(pXY)
    print()
    
    pX = marginal_fst(pXY)
    pY = marginal_snd(pXY)
    
    print(f"Marginal p_X: {pX}")
    print(f"Marginal p_Y: {pY}")
    print(f"V(X) = max p_X(x) = {max_mass(pX):.4f}")
    print(f"H∞(X) = {min_entropy(pX):.4f} bits")
    print(f"V(X|Y) = Σ_y max_x p(x,y) = {cond_vulnerability(pXY):.4f}")
    print(f"H∞(X|Y) = {cond_min_entropy(pXY):.4f} bits")
    print(f"I∞(X;Y) = {tropical_mi(pXY):.4f} bits")
    print()
    
    # Apply a deterministic function f: {0,1} → {0}  (constant)
    f_const = lambda y: 0
    pXfY = pushforward_snd(pXY, f_const, 1)
    print(f"After constant function f(y)=0:")
    print(f"  I∞(X;f(Y)) = {tropical_mi(pXfY):.4f} bits")
    print(f"  DPI check: {tropical_mi(pXfY):.4f} ≤ {tropical_mi(pXY):.4f}? {tropical_mi(pXfY) <= tropical_mi(pXY) + 1e-10}")
    print()

def demo_dpi_statistical():
    """Statistical verification of the DPI over many random distributions."""
    print("=" * 60)
    print("DEMO 2: Data-Processing Inequality (Statistical)")
    print("=" * 60)
    
    rng = np.random.default_rng(42)
    n_trials = 10000
    n_x, n_y, n_z = 3, 4, 2
    
    violations = 0
    info_losses = []
    
    for _ in range(n_trials):
        pXY = random_joint(n_x, n_y, rng)
        f = random_function(n_y, n_z, rng)
        
        mi_original = tropical_mi(pXY)
        pXfY = pushforward_snd(pXY, f, n_z)
        mi_processed = tropical_mi(pXfY)
        
        if mi_processed > mi_original + 1e-10:
            violations += 1
        
        if mi_original > 1e-10:
            info_losses.append((mi_original - mi_processed) / mi_original)
    
    print(f"Trials: {n_trials}")
    print(f"DPI violations: {violations}")
    print(f"Average relative information loss: {np.mean(info_losses):.2%}")
    print(f"Max relative information loss: {np.max(info_losses):.2%}")
    print(f"Min relative information loss: {np.min(info_losses):.2%}")
    print()

def demo_nonnegativity():
    """Verify nonnegativity over many random distributions."""
    print("=" * 60)
    print("DEMO 3: Nonnegativity I∞(X;Y) ≥ 0")
    print("=" * 60)
    
    rng = np.random.default_rng(123)
    n_trials = 10000
    min_mi = float('inf')
    
    for _ in range(n_trials):
        n_x = rng.integers(2, 6)
        n_y = rng.integers(2, 6)
        pXY = random_joint(n_x, n_y, rng)
        mi = tropical_mi(pXY)
        min_mi = min(min_mi, mi)
    
    print(f"Trials: {n_trials}")
    print(f"Minimum I∞(X;Y) found: {min_mi:.6f}")
    print(f"Nonnegativity holds: {min_mi >= -1e-10}")
    print()

def demo_independence():
    """Verify I∞ = 0 for product distributions."""
    print("=" * 60)
    print("DEMO 4: Independence → I∞ = 0")
    print("=" * 60)
    
    rng = np.random.default_rng(456)
    n_trials = 1000
    max_mi = 0.0
    
    for _ in range(n_trials):
        n_x = rng.integers(2, 6)
        n_y = rng.integers(2, 6)
        pXY = random_product(n_x, n_y, rng)
        mi = tropical_mi(pXY)
        max_mi = max(max_mi, abs(mi))
    
    print(f"Trials: {n_trials}")
    print(f"Max |I∞| for product distributions: {max_mi:.2e}")
    print(f"Effectively zero: {max_mi < 1e-10}")
    print()

def demo_chain_rule():
    """Verify chain rule inequality H∞(X,Y) ≥ H∞(X|Y)."""
    print("=" * 60)
    print("DEMO 5: Chain Rule Inequality")
    print("=" * 60)
    
    rng = np.random.default_rng(789)
    n_trials = 10000
    violations = 0
    
    for _ in range(n_trials):
        n_x = rng.integers(2, 5)
        n_y = rng.integers(2, 5)
        pXY = random_joint(n_x, n_y, rng)
        
        h_joint = min_entropy(pXY.ravel())
        h_cond = cond_min_entropy(pXY)
        
        if h_joint < h_cond - 1e-10:
            violations += 1
    
    print(f"Trials: {n_trials}")
    print(f"Chain rule violations (H∞(X,Y) < H∞(X|Y)): {violations}")
    print()

def demo_vulnerability_ordering():
    """Show the key vulnerability ordering: V(X,Y) ≤ V(X) ≤ V(X|Y)."""
    print("=" * 60)
    print("DEMO 6: Vulnerability Ordering")
    print("=" * 60)
    
    rng = np.random.default_rng(101)
    
    for trial in range(5):
        n_x, n_y = 3, 4
        pXY = random_joint(n_x, n_y, rng)
        
        v_joint = max_mass(pXY.ravel())
        v_marginal = max_mass(marginal_fst(pXY))
        v_cond = cond_vulnerability(pXY)
        
        print(f"Trial {trial+1}:")
        print(f"  V(X,Y) = {v_joint:.4f} ≤ V(X) = {v_marginal:.4f} ≤ V(X|Y) = {v_cond:.4f}")
        assert v_joint <= v_marginal + 1e-10
        assert v_marginal <= v_cond + 1e-10
    print()


if __name__ == "__main__":
    demo_basic_example()
    demo_dpi_statistical()
    demo_nonnegativity()
    demo_independence()
    demo_chain_rule()
    demo_vulnerability_ordering()
    
    print("=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Mutual Information — Visualizations

Generate publication-quality charts showing:
1. DPI verification scatter plot
2. Vulnerability ordering diagram
3. Information flow through processing pipeline
4. Leakage profile comparison
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

# ─── Core functions ──────────────────────────────────────────────

def tropical_mi(pXY):
    pX = pXY.sum(axis=1)
    v_x = float(np.max(pX))
    v_xy = float(np.sum(np.max(pXY, axis=0)))
    if v_x <= 0 or v_xy <= 0:
        return 0.0
    return -np.log2(v_x) + np.log2(v_xy)

def cond_vulnerability(pXY):
    return float(np.sum(np.max(pXY, axis=0)))

def min_entropy(p):
    return -np.log2(np.max(p))

def pushforward_snd(pXY, f, n_out):
    n_x, n_y = pXY.shape
    result = np.zeros((n_x, n_out))
    for y in range(n_y):
        result[:, f(y)] += pXY[:, y]
    return result

def random_joint(n_x, n_y, rng):
    raw = rng.exponential(size=(n_x, n_y))
    return raw / raw.sum()


# ═══════════════════════════════════════════════════════════════════
# Figure 1: DPI Scatter Plot
# ═══════════════════════════════════════════════════════════════════

def fig_dpi_scatter():
    """Scatter plot of I∞(X;f(Y)) vs I∞(X;Y) showing DPI holds."""
    rng = np.random.default_rng(42)
    n_trials = 2000
    
    mi_orig = []
    mi_proc = []
    
    for _ in range(n_trials):
        n_x = rng.integers(2, 6)
        n_y = rng.integers(3, 8)
        n_z = rng.integers(2, n_y)
        
        pXY = random_joint(n_x, n_y, rng)
        mapping = rng.integers(0, n_z, size=n_y)
        f = lambda y, m=mapping: int(m[y])
        
        mi_o = tropical_mi(pXY)
        pXfY = pushforward_snd(pXY, f, n_z)
        mi_p = tropical_mi(pXfY)
        
        mi_orig.append(mi_o)
        mi_proc.append(mi_p)
    
    fig, ax = plt.subplots(1, 1, figsize=(8, 7))
    
    max_val = max(max(mi_orig), max(mi_proc)) * 1.1
    ax.plot([0, max_val], [0, max_val], 'r--', linewidth=2, label='I∞(X;f(Y)) = I∞(X;Y)', zorder=5)
    ax.scatter(mi_orig, mi_proc, alpha=0.3, s=15, c='#2196F3', edgecolors='none', zorder=4)
    
    ax.fill_between([0, max_val], [0, max_val], [max_val, max_val],
                     alpha=0.08, color='red', label='DPI violation zone')
    
    ax.set_xlabel('I∞(X; Y)  [original, bits]', fontsize=13)
    ax.set_ylabel('I∞(X; f(Y))  [post-processed, bits]', fontsize=13)
    ax.set_title('Data-Processing Inequality: I∞(X; f(Y)) ≤ I∞(X; Y)', fontsize=15, fontweight='bold')
    ax.legend(fontsize=11, loc='upper left')
    ax.set_xlim(0, max_val)
    ax.set_ylim(0, max_val)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    
    # Add annotation
    ax.annotate('All points below\nthe diagonal line\n(DPI satisfied)',
                xy=(max_val*0.6, max_val*0.3), fontsize=11,
                ha='center', style='italic', color='#1565C0')
    
    plt.tight_layout()
    plt.savefig('fig_dpi_scatter.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: fig_dpi_scatter.png")


# ═══════════════════════════════════════════════════════════════════
# Figure 2: Vulnerability Ordering
# ═══════════════════════════════════════════════════════════════════

def fig_vulnerability_ordering():
    """Bar chart showing V(X,Y) ≤ V(X) ≤ V(X|Y) across distributions."""
    rng = np.random.default_rng(123)
    n_samples = 12
    
    v_joint = []
    v_marg = []
    v_cond = []
    
    for _ in range(n_samples):
        n_x = rng.integers(2, 5)
        n_y = rng.integers(2, 5)
        pXY = random_joint(n_x, n_y, rng)
        
        v_joint.append(float(np.max(pXY)))
        v_marg.append(float(np.max(pXY.sum(axis=1))))
        v_cond.append(cond_vulnerability(pXY))
    
    fig, ax = plt.subplots(1, 1, figsize=(10, 5))
    
    x = np.arange(n_samples)
    width = 0.25
    
    bars1 = ax.bar(x - width, v_joint, width, label='V(X,Y)', color='#4CAF50', alpha=0.85)
    bars2 = ax.bar(x, v_marg, width, label='V(X)', color='#FF9800', alpha=0.85)
    bars3 = ax.bar(x + width, v_cond, width, label='V(X|Y)', color='#F44336', alpha=0.85)
    
    ax.set_xlabel('Distribution index', fontsize=12)
    ax.set_ylabel('Vulnerability', fontsize=12)
    ax.set_title('Vulnerability Ordering: V(X,Y) ≤ V(X) ≤ V(X|Y)', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_xticks(x)
    ax.grid(True, axis='y', alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('fig_vulnerability_ordering.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: fig_vulnerability_ordering.png")


# ═══════════════════════════════════════════════════════════════════
# Figure 3: Information Flow Pipeline
# ═══════════════════════════════════════════════════════════════════

def fig_info_pipeline():
    """Show monotonic decrease of I∞ through a processing pipeline."""
    rng = np.random.default_rng(456)
    
    n_x = 4
    sizes = [16, 8, 4, 2, 1]
    
    # Generate initial distribution
    pXY = random_joint(n_x, sizes[0], rng)
    
    mis = [tropical_mi(pXY)]
    vulns = [cond_vulnerability(pXY)]
    current = pXY
    
    for i in range(1, len(sizes)):
        n_out = sizes[i]
        n_in = sizes[i-1]
        f = lambda y, n=n_out, m=n_in: y * n // m
        current = pushforward_snd(current, f, n_out)
        mis.append(tropical_mi(current))
        vulns.append(cond_vulnerability(current))
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: MI decreasing
    ax1.plot(range(len(sizes)), mis, 'o-', color='#2196F3', linewidth=2.5, markersize=10)
    ax1.fill_between(range(len(sizes)), mis, alpha=0.15, color='#2196F3')
    for i, (s, m) in enumerate(zip(sizes, mis)):
        ax1.annotate(f'|Y|={s}\nI∞={m:.3f}', (i, m), textcoords="offset points",
                     xytext=(0, 15), ha='center', fontsize=9)
    ax1.set_xlabel('Processing stage', fontsize=12)
    ax1.set_ylabel('I∞(X; processed Y) [bits]', fontsize=12)
    ax1.set_title('Tropical MI Through Pipeline', fontsize=14, fontweight='bold')
    ax1.set_xticks(range(len(sizes)))
    ax1.set_xticklabels([f'Stage {i}' for i in range(len(sizes))])
    ax1.grid(True, alpha=0.3)
    
    # Right: Vulnerability increasing (inverted security)
    ax2.plot(range(len(sizes)), vulns, 's-', color='#F44336', linewidth=2.5, markersize=10)
    ax2.fill_between(range(len(sizes)), vulns, alpha=0.15, color='#F44336')
    for i, (s, v) in enumerate(zip(sizes, vulns)):
        ax2.annotate(f'V={v:.3f}', (i, v), textcoords="offset points",
                     xytext=(0, 12), ha='center', fontsize=9)
    ax2.set_xlabel('Processing stage', fontsize=12)
    ax2.set_ylabel('V(X | processed Y)', fontsize=12)
    ax2.set_title('Vulnerability Decreasing (Security Improves)', fontsize=14, fontweight='bold')
    ax2.set_xticks(range(len(sizes)))
    ax2.set_xticklabels([f'Stage {i}' for i in range(len(sizes))])
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('fig_info_pipeline.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: fig_info_pipeline.png")


# ═══════════════════════════════════════════════════════════════════
# Figure 4: DPI Information Loss Distribution
# ═══════════════════════════════════════════════════════════════════

def fig_info_loss_histogram():
    """Histogram of relative information loss under random post-processing."""
    rng = np.random.default_rng(789)
    n_trials = 5000
    
    losses = []
    for _ in range(n_trials):
        n_x = rng.integers(2, 5)
        n_y = rng.integers(3, 8)
        n_z = rng.integers(2, n_y)
        
        pXY = random_joint(n_x, n_y, rng)
        mapping = rng.integers(0, n_z, size=n_y)
        f = lambda y, m=mapping: int(m[y])
        
        mi_o = tropical_mi(pXY)
        pXfY = pushforward_snd(pXY, f, n_z)
        mi_p = tropical_mi(pXfY)
        
        if mi_o > 0.01:
            losses.append((mi_o - mi_p) / mi_o * 100)
    
    fig, ax = plt.subplots(1, 1, figsize=(9, 5))
    
    ax.hist(losses, bins=50, color='#4CAF50', alpha=0.8, edgecolor='white', linewidth=0.5)
    ax.axvline(np.mean(losses), color='#F44336', linewidth=2, linestyle='--',
               label=f'Mean loss: {np.mean(losses):.1f}%')
    ax.axvline(np.median(losses), color='#FF9800', linewidth=2, linestyle=':',
               label=f'Median loss: {np.median(losses):.1f}%')
    
    ax.set_xlabel('Relative information loss (%)', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Distribution of Information Loss Under Random Post-Processing',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    plt.savefig('fig_info_loss_hist.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: fig_info_loss_hist.png")


if __name__ == "__main__":
    fig_dpi_scatter()
    fig_vulnerability_ordering()
    fig_info_pipeline()
    fig_info_loss_histogram()
    print("\nAll visualizations generated!")
