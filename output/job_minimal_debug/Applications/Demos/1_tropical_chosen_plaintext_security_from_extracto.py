#!/usr/bin/env python3
"""
Applications of Tropical CPA Security
======================================

Real-world applications demonstrating how tropical randomness extraction
can support operational encryption security.

Applications:
1. Tropical key generation for symmetric encryption
2. Mixing time analysis for security parameter selection
3. Post-processing robustness verification
4. Multi-party key agreement from tropical semigroups
"""

import numpy as np
from algorithms import (ProbDist, tropical_orbit_sample, tropical_matrix_mult,
                        universal_hash_extract, compute_security_params)


# ─── Application 1: Tropical Key Generation ──────────────────────

def tropical_keygen(dim: int = 4, num_generators: int = 3,
                     orbit_length: int = 20, key_bits: int = 128):
    """Generate a symmetric encryption key from a tropical orbit source.

    This demonstrates the full pipeline:
    1. Define tropical semigroup generators
    2. Run orbit (random walk in semigroup)
    3. Extract key via universal hash
    4. Report security estimate

    Args:
        dim: Matrix dimension
        num_generators: Number of semigroup generators
        orbit_length: Length of random walk
        key_bits: Desired key length in bits
    """
    print("Application 1: Tropical Key Generation")
    print("=" * 50)

    key_size = 2 ** min(key_bits, 8)  # Use 8 bits for demo
    actual_key_bits = int(np.log2(key_size))

    # Generate random tropical semigroup
    generators = [np.random.randn(dim, dim) * 3 for _ in range(num_generators)]

    print(f"  Matrix dimension: {dim}×{dim}")
    print(f"  Generators: {num_generators}")
    print(f"  Orbit length: {orbit_length}")
    print(f"  Key space: {key_size} ({actual_key_bits} bits)")

    # Generate key
    seed = np.random.randn(dim * dim)
    matrix = tropical_orbit_sample(generators, orbit_length)
    key = universal_hash_extract(matrix, seed, key_size)

    print(f"\n  Generated key: {key}")

    # Security analysis
    params = compute_security_params(generators, orbit_length, key_size, 10, 5000)
    print(f"  Statistical distance from uniform: {params.stat_dist_bound:.6f}")
    print(f"  CPA advantage bound (q=10): {params.cpa_advantage_bound:.6f}")
    print(f"  Effective security: {params.security_bits:.1f} bits")

    return key


# ─── Application 2: Mixing Time Analysis ─────────────────────────

def mixing_time_analysis(dim: int = 3, target_security: float = 1e-3):
    """Analyze how many orbit steps are needed for target security.

    Demonstrates parameter selection for tropical cryptographic schemes.
    """
    print("\n\nApplication 2: Mixing Time Analysis")
    print("=" * 50)

    key_size = 16
    generators = [np.random.randn(dim, dim) * 2 for _ in range(3)]

    print(f"  Target security (statDist): ≤ {target_security}")
    print(f"  Key space: {key_size}")
    print(f"\n  {'Steps':>6s} | {'StatDist':>10s} | {'Meets target':>12s}")
    print("  " + "-" * 36)

    best_steps = None
    for steps in [1, 2, 3, 5, 8, 10, 15, 20, 30, 50, 100]:
        params = compute_security_params(generators, steps, key_size, 10, 3000)
        meets = params.stat_dist_bound <= target_security
        marker = "✓" if meets else ""
        print(f"  {steps:6d} | {params.stat_dist_bound:10.6f} | {marker:>12s}")
        if meets and best_steps is None:
            best_steps = steps

    if best_steps:
        print(f"\n  Minimum orbit length for target security: {best_steps}")
    else:
        print(f"\n  Target not achieved in tested range.")


# ─── Application 3: Post-Processing Robustness ───────────────────

def post_processing_robustness():
    """Verify that key derivation (post-processing) preserves security.

    Demonstrates the composition theorem: applying any deterministic
    function to the key cannot increase the adversary's advantage.
    """
    print("\n\nApplication 3: Post-Processing Robustness")
    print("=" * 50)

    key_size = 32
    derived_size = 8

    # Generate a slightly non-uniform distribution
    real = ProbDist(np.random.dirichlet(np.ones(key_size) * 5))
    uniform = ProbDist.uniform(key_size)
    original_sd = real.stat_dist(uniform)

    print(f"  Original key space: {key_size}")
    print(f"  Derived key space: {derived_size}")
    print(f"  Original statDist: {original_sd:.6f}")

    # Try various post-processing functions
    functions = {
        "mod reduction": lambda x: x % derived_size,
        "bit truncation": lambda x: x >> 2,
        "hash (random)": lambda x, p=np.random.permutation(key_size) % derived_size: p[x],
    }

    print(f"\n  {'Function':>20s} | {'Derived SD':>10s} | {'≤ Original':>10s}")
    print("  " + "-" * 48)

    for name, f in functions.items():
        derived_real = ProbDist.map(f, real, derived_size)
        derived_unif = ProbDist.map(f, uniform, derived_size)
        derived_sd = derived_real.stat_dist(derived_unif)
        holds = derived_sd <= original_sd + 1e-10
        print(f"  {name:>20s} | {derived_sd:10.6f} | {'✓' if holds else '✗':>10s}")


# ─── Application 4: Multi-Party Key Agreement ────────────────────

def tropical_key_agreement():
    """Simulate a two-party key agreement using tropical semigroups.

    Protocol:
    1. Public parameters: tropical generators G1, G2, ..., Gm
    2. Alice picks random word a = (a1, ..., at), computes A = Ga1 ⊗ ... ⊗ Gat
    3. Bob picks random word b = (b1, ..., bt), computes B = Gb1 ⊗ ... ⊗ Gbt
    4. Alice computes shared = A ⊗ B, Bob computes shared = A ⊗ B
       (In practice, more sophisticated commutative constructions are used)
    5. Both extract key from shared matrix
    """
    print("\n\nApplication 4: Tropical Key Agreement Simulation")
    print("=" * 50)

    dim = 3
    num_generators = 4
    steps = 15
    key_size = 16

    generators = [np.random.randn(dim, dim) * 2 for _ in range(num_generators)]
    seed = np.random.randn(dim * dim)

    # Alice's computation
    alice_matrix = tropical_orbit_sample(generators, steps)
    # Bob's computation
    bob_matrix = tropical_orbit_sample(generators, steps)

    # Shared secret (simplified: Alice ⊗ Bob)
    shared = tropical_matrix_mult(alice_matrix, bob_matrix)

    # Key extraction
    alice_key = universal_hash_extract(shared, seed, key_size)

    print(f"  Dimension: {dim}×{dim}")
    print(f"  Generators: {num_generators}")
    print(f"  Steps per party: {steps}")
    print(f"  Key space: {key_size}")
    print(f"\n  Shared key: {alice_key}")

    # Security of extracted key
    params = compute_security_params(generators, 2 * steps, key_size, 10, 3000)
    print(f"  StatDist bound: {params.stat_dist_bound:.6f}")
    print(f"  CPA advantage (q=10): {params.cpa_advantage_bound:.6f}")


# ─── Main ─────────────────────────────────────────────────────────

if __name__ == "__main__":
    np.random.seed(2025)

    tropical_keygen()
    mixing_time_analysis()
    post_processing_robustness()
    tropical_key_agreement()

    print("\n" + "=" * 50)
    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Tropical CPA Security Demo
===========================

Demonstrates the core theorems connecting tropical randomness extraction
to chosen-plaintext security for symmetric encryption.

Key results illustrated:
1. Statistical distance between extracted key and uniform
2. CPA advantage bounds as a function of statistical distance
3. Data processing inequality: post-processing cannot increase distance
4. Full pipeline: tropical source → extraction → CPA security
"""

import numpy as np
from typing import Callable

# ─── Probability Distribution Helpers ─────────────────────────────

def normalize(p: np.ndarray) -> np.ndarray:
    """Normalize to a valid probability distribution."""
    p = np.maximum(p, 0)
    return p / p.sum()

def uniform(n: int) -> np.ndarray:
    """Uniform distribution on n elements."""
    return np.ones(n) / n

def stat_dist(p: np.ndarray, q: np.ndarray) -> float:
    """Statistical distance (total variation distance)."""
    return 0.5 * np.sum(np.abs(p - q))

def l1_dist(p: np.ndarray, q: np.ndarray) -> float:
    """L1 distance between distributions."""
    return np.sum(np.abs(p - q))

# ─── Tropical Semigroup Source ────────────────────────────────────

def tropical_matrix_mult(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical (max-plus) matrix multiplication."""
    n, m = A.shape[0], B.shape[1]
    C = np.full((n, m), -np.inf)
    for i in range(n):
        for j in range(m):
            C[i, j] = np.max(A[i, :] + B[:, j])
    return C

def tropical_orbit_source(generators: list, steps: int, dim: int) -> np.ndarray:
    """Generate a tropical orbit by random composition of generators."""
    state = np.zeros((dim, dim))  # tropical identity
    np.fill_diagonal(state, 0)
    state[state == 0] = 0
    state[np.eye(dim) == 0] = -np.inf

    trajectory = []
    for _ in range(steps):
        g = generators[np.random.randint(len(generators))]
        state = tropical_matrix_mult(state, g)
        trajectory.append(state.copy())

    return trajectory

# ─── Key Extraction ──────────────────────────────────────────────

def extract_key(matrix: np.ndarray, key_size: int) -> int:
    """Extract a key from a tropical matrix by hashing its entries."""
    # Use a simple universal hash: linear combination mod key_size
    flat = matrix.flatten()
    finite_entries = flat[np.isfinite(flat)]
    if len(finite_entries) == 0:
        return 0
    hash_val = int(np.sum(np.abs(finite_entries) * np.arange(1, len(finite_entries) + 1))) % key_size
    return hash_val

def extract_key_distribution(generators: list, steps: int, dim: int,
                              key_size: int, num_samples: int) -> np.ndarray:
    """Estimate the key distribution from tropical orbit extraction."""
    counts = np.zeros(key_size)
    for _ in range(num_samples):
        orbit = tropical_orbit_source(generators, steps, dim)
        key = extract_key(orbit[-1], key_size)
        counts[key] += 1
    return counts / counts.sum()

# ─── CPA Advantage Computation ───────────────────────────────────

def cpa_advantage(real_key_dist: np.ndarray, uniform_key_dist: np.ndarray,
                  distinguisher: np.ndarray) -> float:
    """Compute CPA advantage for a given distinguisher."""
    real_expectation = np.sum(real_key_dist * distinguisher)
    ideal_expectation = np.sum(uniform_key_dist * distinguisher)
    return abs(real_expectation - ideal_expectation)

def worst_case_distinguisher(real_key_dist: np.ndarray,
                              uniform_key_dist: np.ndarray) -> np.ndarray:
    """Construct the worst-case distinguisher (sign of p - q)."""
    diff = real_key_dist - uniform_key_dist
    return np.sign(diff)

# ─── Demo 1: Basic Statistical Distance and CPA Bound ────────────

def demo_basic_bounds():
    """Demonstrate the basic CPA bound from statistical distance."""
    print("=" * 60)
    print("Demo 1: CPA Advantage Bounds from Statistical Distance")
    print("=" * 60)

    key_size = 16
    u = uniform(key_size)

    # Create a "real" key distribution (slightly non-uniform)
    real = normalize(np.random.dirichlet(np.ones(key_size) * 5))

    sd = stat_dist(real, u)
    l1 = l1_dist(real, u)

    # Worst-case distinguisher
    worst = worst_case_distinguisher(real, u)
    adv_worst = cpa_advantage(real, u, worst)

    # Random bounded distinguisher
    random_dist = np.random.uniform(-1, 1, key_size)
    adv_random = cpa_advantage(real, u, random_dist)

    print(f"\nKey space size: {key_size}")
    print(f"Statistical distance: {sd:.6f}")
    print(f"L1 distance: {l1:.6f}")
    print(f"\nTheorem: CPA advantage ≤ L1 distance = 2 × statDist")
    print(f"  Worst-case adversary advantage: {adv_worst:.6f}")
    print(f"  2 × statDist bound:             {2 * sd:.6f}")
    print(f"  Bound holds: {adv_worst <= 2 * sd + 1e-10}")
    print(f"\n  Random adversary advantage:     {adv_random:.6f}")
    print(f"  L1 bound:                       {l1:.6f}")
    print(f"  Bound holds: {adv_random <= l1 + 1e-10}")

    # q * ε bound
    for q in [2, 5, 10, 100]:
        bound = q * sd
        print(f"\n  q={q:3d} queries: advantage ≤ q×statDist = {bound:.6f}")

# ─── Demo 2: Data Processing Inequality ──────────────────────────

def demo_data_processing():
    """Demonstrate that post-processing cannot increase statistical distance."""
    print("\n" + "=" * 60)
    print("Demo 2: Data Processing Inequality")
    print("=" * 60)

    n = 32
    m = 8  # smaller output space

    p = normalize(np.random.dirichlet(np.ones(n) * 2))
    q = uniform(n)

    sd_original = stat_dist(p, q)

    # Apply various post-processing functions
    print(f"\nOriginal stat. distance (n={n}): {sd_original:.6f}")
    print(f"\nAfter post-processing (deterministic functions f: [n] → [m]):")

    for trial, name in enumerate(["mod reduction", "threshold", "random hash"]):
        if trial == 0:
            f = lambda x: x % m
        elif trial == 1:
            f = lambda x: min(x, m - 1)
        else:
            perm = np.random.permutation(n) % m
            f = lambda x, p=perm: p[x]

        # Compute pushforward distributions
        p_push = np.zeros(m)
        q_push = np.zeros(m)
        for x in range(n):
            y = f(x)
            p_push[y] += p[x]
            q_push[y] += q[x]

        sd_push = stat_dist(p_push, q_push)
        print(f"  {name:20s}: statDist = {sd_push:.6f} ≤ {sd_original:.6f} ✓"
              if sd_push <= sd_original + 1e-10
              else f"  {name:20s}: statDist = {sd_push:.6f} > {sd_original:.6f} ✗")

# ─── Demo 3: Tropical Source → CPA Security Pipeline ─────────────

def demo_tropical_pipeline():
    """Full pipeline: tropical orbit → extraction → CPA security."""
    print("\n" + "=" * 60)
    print("Demo 3: Tropical Source → CPA Security Pipeline")
    print("=" * 60)

    dim = 3
    key_size = 16
    num_samples = 5000

    # Create tropical generators
    np.random.seed(42)
    generators = []
    for _ in range(3):
        G = np.random.randn(dim, dim) * 2
        generators.append(G)

    print(f"\nTropical dimension: {dim}×{dim}")
    print(f"Number of generators: {len(generators)}")
    print(f"Key space size: {key_size}")
    print(f"Samples per estimate: {num_samples}")

    u = uniform(key_size)

    print(f"\n{'Steps':>6s} | {'StatDist':>10s} | {'CPA bound (q=10)':>16s} | {'CPA bound (q=2)':>16s}")
    print("-" * 60)

    for steps in [1, 2, 5, 10, 20, 50]:
        key_dist = extract_key_distribution(generators, steps, dim, key_size, num_samples)
        sd = stat_dist(key_dist, u)
        print(f"{steps:6d} | {sd:10.6f} | {10 * sd:16.6f} | {2 * sd:16.6f}")

    print("\nAs orbit length increases, the key distribution converges to")
    print("uniform, and CPA security improves (smaller advantage bound).")

# ─── Demo 4: KL Divergence → CPA Security (Pinsker Bridge) ───────

def demo_pinsker_bridge():
    """Demonstrate CPA bounds via KL divergence and Pinsker's inequality."""
    print("\n" + "=" * 60)
    print("Demo 4: KL → TV → CPA (Pinsker Bridge)")
    print("=" * 60)

    key_size = 16
    u = uniform(key_size)

    print(f"\n{'KL div':>10s} | {'TV (actual)':>12s} | {'TV (Pinsker)':>12s} | "
          f"{'CPA (actual)':>12s} | {'CPA (Pinsker)':>14s}")
    print("-" * 75)

    for alpha in [0.5, 1.0, 2.0, 5.0, 10.0, 50.0]:
        p = normalize(np.random.dirichlet(np.ones(key_size) * alpha))

        # KL divergence
        kl = np.sum(p * np.log(p / u))

        # Actual TV
        tv = stat_dist(p, u)

        # Pinsker bound: TV ≤ sqrt(KL/2)
        tv_pinsker = np.sqrt(kl / 2)

        # Actual CPA (worst case)
        worst = worst_case_distinguisher(p, u)
        cpa_actual = cpa_advantage(p, u, worst)

        # CPA from Pinsker: adv ≤ 2 × sqrt(KL/2) for q=2
        q = 2
        cpa_pinsker = q * tv_pinsker

        print(f"{kl:10.6f} | {tv:12.6f} | {tv_pinsker:12.6f} | "
              f"{cpa_actual:12.6f} | {cpa_pinsker:14.6f}")

    print("\nPinsker's inequality: TV ≤ √(KL/2)")
    print("Combined with CPA theorem: Adv ≤ q × √(KL/2)")

# ─── Main ─────────────────────────────────────────────────────────

if __name__ == "__main__":
    np.random.seed(2025)

    demo_basic_bounds()
    demo_data_processing()
    demo_tropical_pipeline()
    demo_pinsker_bridge()

    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Tropical CPA Security
==========================================

Generates publication-quality figures showing:
1. CPA advantage vs statistical distance
2. Mixing convergence of tropical orbit sources
3. Data processing inequality demonstration
4. Security parameter landscape
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import os

# Style
plt.rcParams.update({
    'font.size': 12,
    'axes.labelsize': 14,
    'axes.titlesize': 15,
    'figure.figsize': (8, 6),
    'figure.dpi': 150,
    'savefig.bbox': 'tight',
    'savefig.pad_inches': 0.1,
})

def normalize(p):
    p = np.maximum(p, 0)
    return p / p.sum()

def stat_dist(p, q):
    return 0.5 * np.sum(np.abs(p - q))


# ─── Figure 1: CPA Advantage Bound ───────────────────────────────

def plot_cpa_bound():
    """CPA advantage as a function of statistical distance."""
    fig, ax = plt.subplots(figsize=(8, 6))

    eps = np.linspace(0, 0.5, 200)

    for q in [2, 5, 10, 20]:
        ax.plot(eps, q * eps, label=f'q = {q}', linewidth=2)

    ax.plot(eps, 2 * eps, '--', color='black', linewidth=1.5,
            label='Sharp: 2ε', alpha=0.7)

    # Add region annotation
    ax.fill_between(eps, 0, 2 * eps, alpha=0.1, color='green',
                     label='Achievable region')

    ax.set_xlabel('Statistical Distance ε')
    ax.set_ylabel('CPA Advantage Bound')
    ax.set_title('CPA Security from Key Distribution Closeness')
    ax.legend(loc='upper left')
    ax.set_xlim(0, 0.5)
    ax.set_ylim(0, 5)
    ax.grid(True, alpha=0.3)

    fig.savefig('fig_cpa_bound.png')
    plt.close()
    print("  Saved fig_cpa_bound.png")


# ─── Figure 2: Tropical Mixing Convergence ───────────────────────

def plot_mixing_convergence():
    """Statistical distance vs orbit length for tropical sources."""
    fig, ax = plt.subplots(figsize=(8, 6))

    np.random.seed(42)
    key_size = 16
    u = np.ones(key_size) / key_size
    num_samples = 3000

    for dim, color, marker in [(2, '#e74c3c', 'o'), (3, '#3498db', 's'),
                                (4, '#2ecc71', '^')]:
        generators = [np.random.randn(dim, dim) * 2 for _ in range(3)]
        steps_list = [1, 2, 3, 5, 8, 10, 15, 20, 30, 50]
        sds = []

        for steps in steps_list:
            counts = np.zeros(key_size)
            for _ in range(num_samples):
                # Tropical orbit
                state = np.full((dim, dim), -np.inf)
                np.fill_diagonal(state, 0)
                for _ in range(steps):
                    g = generators[np.random.randint(3)]
                    n_dim = state.shape[0]
                    C = np.full((n_dim, n_dim), -np.inf)
                    for i in range(n_dim):
                        for j in range(n_dim):
                            C[i,j] = np.max(state[i,:] + g[:,j])
                    state = C
                # Extract key
                flat = state.flatten()
                finite = flat[np.isfinite(flat)]
                key = int(np.sum(np.abs(finite) * np.arange(1, len(finite)+1))) % key_size if len(finite) > 0 else 0
                counts[key] += 1

            dist = counts / counts.sum()
            sds.append(stat_dist(dist, u))

        ax.semilogy(steps_list, sds, f'-{marker}', color=color,
                     label=f'dim = {dim}', linewidth=2, markersize=8)

    ax.axhline(y=0.01, color='gray', linestyle=':', alpha=0.5,
               label='Target: ε = 0.01')
    ax.set_xlabel('Orbit Length (steps)')
    ax.set_ylabel('Statistical Distance to Uniform')
    ax.set_title('Tropical Orbit Mixing → Key Uniformity')
    ax.legend()
    ax.grid(True, alpha=0.3)

    fig.savefig('fig_mixing.png')
    plt.close()
    print("  Saved fig_mixing.png")


# ─── Figure 3: Data Processing Inequality ────────────────────────

def plot_data_processing():
    """Demonstrate DPI: post-processing contracts statistical distance."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    np.random.seed(123)
    n = 32
    m_values = [16, 8, 4]

    p = normalize(np.random.dirichlet(np.ones(n) * 2))
    q = np.ones(n) / n

    for idx, m in enumerate(m_values):
        ax = axes[idx]
        f = lambda x, m=m: x % m

        p_push = np.zeros(m)
        q_push = np.zeros(m)
        for x in range(n):
            y = f(x)
            p_push[y] += p[x]
            q_push[y] += q[x]

        sd_orig = stat_dist(p, q)
        sd_push = stat_dist(p_push, q_push)

        x_pos = np.arange(m)
        width = 0.35
        ax.bar(x_pos - width/2, p_push, width, label='Real', alpha=0.8, color='#e74c3c')
        ax.bar(x_pos + width/2, q_push, width, label='Uniform', alpha=0.8, color='#3498db')

        ax.set_title(f'Output size = {m}\nSD = {sd_push:.4f} ≤ {sd_orig:.4f}')
        ax.set_xlabel('Key value')
        ax.set_ylabel('Probability')
        ax.legend(fontsize=10)

    fig.suptitle('Data Processing Inequality: Post-Processing Contracts Distance',
                 fontsize=14, y=1.02)
    fig.tight_layout()
    fig.savefig('fig_dpi.png')
    plt.close()
    print("  Saved fig_dpi.png")


# ─── Figure 4: Security Landscape ────────────────────────────────

def plot_security_landscape():
    """Security bits as a function of orbit length and key size."""
    fig, ax = plt.subplots(figsize=(8, 6))

    np.random.seed(42)
    dim = 3
    generators = [np.random.randn(dim, dim) * 2 for _ in range(3)]
    num_samples = 2000
    q = 10

    key_sizes = [8, 16, 32]
    colors = ['#e74c3c', '#3498db', '#2ecc71']

    for key_size, color in zip(key_sizes, colors):
        u = np.ones(key_size) / key_size
        steps_list = [2, 5, 10, 15, 20, 30, 50]
        sec_bits = []

        for steps in steps_list:
            counts = np.zeros(key_size)
            for _ in range(num_samples):
                state = np.full((dim, dim), -np.inf)
                np.fill_diagonal(state, 0)
                for _ in range(steps):
                    g = generators[np.random.randint(3)]
                    C = np.full((dim, dim), -np.inf)
                    for i in range(dim):
                        for j in range(dim):
                            C[i,j] = np.max(state[i,:] + g[:,j])
                    state = C
                flat = state.flatten()
                finite = flat[np.isfinite(flat)]
                key = int(np.sum(np.abs(finite) * np.arange(1, len(finite)+1))) % key_size if len(finite) > 0 else 0
                counts[key] += 1

            dist = counts / counts.sum()
            sd = stat_dist(dist, u)
            adv = max(2, q) * sd
            bits = -np.log2(adv) if adv > 0 else 40
            sec_bits.append(min(bits, 40))

        ax.plot(steps_list, sec_bits, '-o', color=color,
                label=f'|K| = {key_size}', linewidth=2, markersize=8)

    ax.axhline(y=10, color='orange', linestyle='--', alpha=0.7,
               label='10-bit security')
    ax.set_xlabel('Orbit Length')
    ax.set_ylabel('Security (bits)')
    ax.set_title(f'Tropical CPA Security vs Orbit Length (q={q})')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 25)

    fig.savefig('fig_security.png')
    plt.close()
    print("  Saved fig_security.png")


# ─── Main ─────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Generating visualizations...")
    plot_cpa_bound()
    plot_mixing_convergence()
    plot_data_processing()
    plot_security_landscape()
    print("\nAll figures generated successfully.")
