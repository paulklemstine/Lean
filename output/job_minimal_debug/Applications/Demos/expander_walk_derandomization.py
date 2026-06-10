#!/usr/bin/env python3
"""
Applications of Expander Walk Derandomization

Real-world applications of the spectral pseudorandomness theory:
1. Randomness-efficient sampling for Monte Carlo simulations
2. Error reduction in probabilistic algorithms
3. Pseudorandom number generation with provable guarantees
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from algorithms import build_lazy_cayley_walk, spectral_gap, expander_walk_prg


# ============================================================
# Application 1: Randomness-Efficient Monte Carlo Integration
# ============================================================
def app_monte_carlo():
    """
    Compare standard Monte Carlo (independent samples) vs.
    expander walk Monte Carlo (correlated but cheap samples).

    Problem: Estimate E[f(X)] where X is uniform on Z/nZ.
    """
    print("=" * 60)
    print("Application 1: Randomness-Efficient Monte Carlo")
    print("=" * 60)

    n = 100
    P = build_lazy_cayley_walk(n, [1, 3, 11, 37], laziness=0.2)
    gap_val, lam = spectral_gap(P)
    print(f"Expander: Z/{n}Z, generators {{1,3,11,37}}, gap={gap_val:.4f}")

    # Target function
    f = np.array([np.sin(2 * np.pi * k / n) + np.cos(6 * np.pi * k / n) for k in range(n)])
    true_mean = np.mean(f)
    print(f"True mean E[f] = {true_mean:.6f}")

    num_trials = 500
    sample_sizes = [10, 20, 50, 100, 200, 500]

    iid_errors = []
    walk_errors = []

    for T in sample_sizes:
        iid_errs = []
        walk_errs = []
        for _ in range(num_trials):
            # IID sampling
            iid_samples = np.random.choice(n, size=T)
            iid_mean = np.mean(f[iid_samples])
            iid_errs.append(abs(iid_mean - true_mean))

            # Walk sampling
            seed = np.random.randint(n)
            walk = expander_walk_prg(P, seed, T - 1)
            walk_mean = np.mean(f[walk])
            walk_errs.append(abs(walk_mean - true_mean))

        iid_errors.append(np.mean(iid_errs))
        walk_errors.append(np.mean(walk_errs))

    print(f"\n{'T':>5}  {'IID error':>12}  {'Walk error':>12}  {'Ratio':>8}")
    print("-" * 45)
    for i, T in enumerate(sample_sizes):
        ratio = iid_errors[i] / walk_errors[i] if walk_errors[i] > 0 else float('inf')
        print(f"{T:5d}  {iid_errors[i]:12.6f}  {walk_errors[i]:12.6f}  {ratio:8.2f}")

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.loglog(sample_sizes, iid_errors, 'bo-', linewidth=2, label='IID sampling')
    ax.loglog(sample_sizes, walk_errors, 'rs-', linewidth=2, label='Expander walk')
    ax.set_xlabel('Number of samples T', fontsize=12)
    ax.set_ylabel('Mean absolute error', fontsize=12)
    ax.set_title('Monte Carlo: IID vs. Expander Walk Sampling', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('monte_carlo_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n→ Saved monte_carlo_comparison.png")


# ============================================================
# Application 2: Error Amplification Comparison
# ============================================================
def app_error_amplification():
    """
    Compare error reduction rates:
    - Independent repetition: error ≤ (1/3)^t, bits = O(t·n)
    - Expander walk: error ≤ λ^t, bits = O(n + t)
    """
    print("\n" + "=" * 60)
    print("Application 2: Error Amplification")
    print("=" * 60)

    n_param = 20  # state space ~ 3^20

    # Simulate a BPP algorithm on Z/nZ
    n = 81  # ~ 3^4 for tractability
    P = build_lazy_cayley_walk(n, [1, 4, 13], laziness=0.3)
    gap_val, lam = spectral_gap(P)

    # "Algorithm" that accepts vertex v if v < n/2 + n/6
    # (correct answer: accept, probability ~2/3)
    threshold = int(n * 2 / 3)
    accept = lambda v: v < threshold

    print(f"\nSimulated BPP algorithm on Z/{n}Z")
    print(f"True acceptance prob: {threshold/n:.3f}")
    print(f"Spectral gap: {gap_val:.4f}, λ = {lam:.4f}")

    walk_lengths = range(1, 30)
    independent_errors = []
    walk_errors = []

    num_trials = 2000
    for t in walk_lengths:
        # Independent: majority of t independent samples
        ind_correct = 0
        walk_correct = 0
        for _ in range(num_trials):
            # Independent
            samples = np.random.choice(n, size=t)
            majority = sum(accept(v) for v in samples) > t / 2
            if majority:
                ind_correct += 1

            # Walk
            seed = np.random.randint(n)
            walk = expander_walk_prg(P, seed, t - 1)
            majority = sum(accept(v) for v in walk) > t / 2
            if majority:
                walk_correct += 1

        independent_errors.append(1 - ind_correct / num_trials)
        walk_errors.append(1 - walk_correct / num_trials)

    # Bits comparison
    print(f"\n{'t':>3}  {'Ind. error':>10}  {'Walk error':>10}  {'Ind. bits':>10}  {'Walk bits':>10}")
    print("-" * 50)
    for t in [1, 5, 10, 15, 20, 25]:
        if t <= len(independent_errors):
            ind_bits = t * int(np.ceil(np.log2(n)))
            walk_bits = int(np.ceil(np.log2(n))) + (t - 1)
            print(f"{t:3d}  {independent_errors[t-1]:10.4f}  {walk_errors[t-1]:10.4f}  "
                  f"{ind_bits:10d}  {walk_bits:10d}")

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ts = list(walk_lengths)
    ax1.semilogy(ts, [max(e, 1e-4) for e in independent_errors], 'b-o',
                 markersize=3, linewidth=2, label='Independent repetition')
    ax1.semilogy(ts, [max(e, 1e-4) for e in walk_errors], 'r-s',
                 markersize=3, linewidth=2, label='Expander walk')
    ax1.set_xlabel('Number of trials t', fontsize=12)
    ax1.set_ylabel('Error probability', fontsize=12)
    ax1.set_title('Error Amplification', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Bits comparison
    ind_bits = [t * int(np.ceil(np.log2(n))) for t in ts]
    walk_bits = [int(np.ceil(np.log2(n))) + (t - 1) for t in ts]
    ax2.plot(ts, ind_bits, 'b-o', markersize=3, linewidth=2, label='Independent bits')
    ax2.plot(ts, walk_bits, 'r-s', markersize=3, linewidth=2, label='Walk bits')
    ax2.set_xlabel('Number of trials t', fontsize=12)
    ax2.set_ylabel('Random bits needed', fontsize=12)
    ax2.set_title('Randomness Cost', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('error_amplification.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n→ Saved error_amplification.png")


# ============================================================
# Application 3: Pseudorandom Generator Quality
# ============================================================
def app_prg_quality():
    """
    Test the quality of expander walk PRG against various statistical tests.
    """
    print("\n" + "=" * 60)
    print("Application 3: PRG Quality Testing")
    print("=" * 60)

    n = 64
    P = build_lazy_cayley_walk(n, [1, 5, 17, 23], laziness=0.2)
    gap_val, lam = spectral_gap(P)
    print(f"PRG: expander walk on Z/{n}Z, gap={gap_val:.4f}")

    # Generate sequences
    walk_len = 1000
    seed = np.random.randint(n)
    walk_seq = expander_walk_prg(P, seed, walk_len)
    iid_seq = list(np.random.choice(n, size=walk_len + 1))

    # Test 1: Frequency test (should be uniform)
    walk_hist = np.bincount(walk_seq, minlength=n) / len(walk_seq)
    iid_hist = np.bincount(iid_seq, minlength=n) / len(iid_seq)
    uniform = np.ones(n) / n

    walk_freq_err = np.max(np.abs(walk_hist - uniform))
    iid_freq_err = np.max(np.abs(iid_hist - uniform))

    print(f"\nFrequency test (max deviation from uniform):")
    print(f"  Walk: {walk_freq_err:.6f}")
    print(f"  IID:  {iid_freq_err:.6f}")

    # Test 2: Serial correlation
    walk_autocorr = np.corrcoef(walk_seq[:-1], walk_seq[1:])[0, 1]
    iid_autocorr = np.corrcoef(iid_seq[:-1], iid_seq[1:])[0, 1]

    print(f"\nSerial correlation (lag 1):")
    print(f"  Walk: {walk_autocorr:.6f}")
    print(f"  IID:  {iid_autocorr:.6f}")
    print(f"  Theory bound: λ = {lam:.6f}")

    # Test 3: Parity test (character test)
    walk_parity = np.mean([(-1)**v for v in walk_seq])
    iid_parity = np.mean([(-1)**v for v in iid_seq])

    print(f"\nParity bias (E[(-1)^X]):")
    print(f"  Walk: {walk_parity:.6f}")
    print(f"  IID:  {iid_parity:.6f}")
    print(f"  Expected: ~0")

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    axes[0].bar(range(n), walk_hist, alpha=0.7, label='Walk')
    axes[0].axhline(y=1/n, color='r', linestyle='--', label='Uniform')
    axes[0].set_title('Frequency Distribution', fontsize=12)
    axes[0].set_xlabel('Vertex')
    axes[0].set_ylabel('Frequency')
    axes[0].legend()

    lags = range(1, 20)
    walk_acf = [np.corrcoef(walk_seq[:-l], walk_seq[l:])[0, 1] for l in lags]
    iid_acf = [np.corrcoef(iid_seq[:-l], iid_seq[l:])[0, 1] for l in lags]
    axes[1].bar([l - 0.2 for l in lags], [abs(x) for x in walk_acf], 0.4,
                alpha=0.7, label='Walk', color='steelblue')
    axes[1].bar([l + 0.2 for l in lags], [abs(x) for x in iid_acf], 0.4,
                alpha=0.7, label='IID', color='coral')
    axes[1].plot(lags, [lam**l for l in lags], 'k--', linewidth=2, label='λ^t bound')
    axes[1].set_title('Autocorrelation Decay', fontsize=12)
    axes[1].set_xlabel('Lag')
    axes[1].set_ylabel('|Autocorrelation|')
    axes[1].legend()

    # Cumulative distribution
    walk_sorted = np.sort(walk_seq) / n
    iid_sorted = np.sort(iid_seq) / n
    axes[2].plot(walk_sorted, np.linspace(0, 1, len(walk_sorted)), label='Walk CDF')
    axes[2].plot(iid_sorted, np.linspace(0, 1, len(iid_sorted)), label='IID CDF')
    axes[2].plot([0, 1], [0, 1], 'k--', label='Uniform CDF')
    axes[2].set_title('CDF Comparison', fontsize=12)
    axes[2].set_xlabel('Value')
    axes[2].set_ylabel('CDF')
    axes[2].legend()

    plt.tight_layout()
    plt.savefig('prg_quality.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n→ Saved prg_quality.png")


if __name__ == "__main__":
    app_monte_carlo()
    app_error_amplification()
    app_prg_quality()
    print("\n" + "=" * 60)
    print("All applications completed!")
    print("=" * 60)


#!/usr/bin/env python3
"""Build PACKAGE.json with all artifacts."""

import json
import base64

# Read markdown files
with open('ARTICLE.md', 'r') as f:
    article = f.read()

with open('RESEARCH_PAPER.md', 'r') as f:
    research_paper = f.read()

with open('FUTURE_DIRECTIONS.md', 'r') as f:
    future_directions = f.read()

# Read Lean files
lean_files = [
    'Catalog/Algebra/ExpanderWalk/Core.lean',
    'Catalog/Algebra/ExpanderWalk/SeedLength.lean',
]
lean_proofs = ""
for f_path in lean_files:
    with open(f_path, 'r') as f:
        lean_proofs += f"-- File: {f_path}\n" + f.read() + "\n\n"

# Read Python files
with open('demo.py', 'r') as f:
    demo_code = f.read()

with open('algorithms.py', 'r') as f:
    algorithms_code = f.read()

with open('applications.py', 'r') as f:
    applications_code = f.read()

# Read images
images = {}
for name in ['spectral_mixing', 'correlation_decay', 'seed_length', 'eigenvalue_spectrum']:
    try:
        with open(f'{name}.png', 'rb') as f:
            data = base64.b64encode(f.read()).decode()
            images[name] = f'data:image/png;base64,{data}'
    except FileNotFoundError:
        images[name] = ""

# Build package
package = {
    "title": "Certified Spectral Pseudorandomness: Formalized Expander Walk Derandomization",
    "domain": "Algebra / Spectral Graph Theory / Pseudorandomness",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Expander Walk Demonstrations",
            "code": demo_code
        },
        {
            "name": "Applications of Expander Walk Derandomization",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Expander Walk PRG",
            "pseudocode": (
                "EXPANDER-WALK-PRG(P, seed, t):\n"
                "  Input: n×n stochastic matrix P, initial vertex seed, walk length t\n"
                "  Output: sequence of (t+1) vertices\n"
                "  1. v₀ ← seed mod n\n"
                "  2. for i = 1 to t:\n"
                "       vᵢ ← sample neighbor of v_{i-1} according to P[v_{i-1}, :]\n"
                "  3. return (v₀, v₁, ..., vₜ)\n"
                "  \n"
                "  Seed length: ⌈log₂ n⌉ + t · ⌈log₂ d⌉ bits\n"
                "  By Theorem C: for n ≤ 3^m, seed ≤ 2m + t·⌈log₂ d⌉ bits"
            ),
            "code": algorithms_code
        },
        {
            "name": "Spectral Gap Computation",
            "pseudocode": (
                "SPECTRAL-GAP(P):\n"
                "  Input: n×n symmetric stochastic matrix P\n"
                "  Output: spectral gap δ, second eigenvalue λ\n"
                "  1. Compute eigenvalues λ₁ ≥ λ₂ ≥ ... ≥ λₙ of P\n"
                "  2. λ ← max(|λ₂|, |λₙ|)\n"
                "  3. δ ← 1 - λ\n"
                "  4. return (δ, λ)\n"
                "  \n"
                "  Time: O(n³) via eigendecomposition\n"
                "  By Theorem 3.7: λ = 1 - δ ∈ [0, 1)"
            ),
            "code": "# See algorithms.py spectral_gap() function"
        },
        {
            "name": "Mixing Time Estimation",
            "pseudocode": (
                "MIXING-TIME(P, ε):\n"
                "  Input: stochastic matrix P, target error ε > 0\n"
                "  Output: mixing time t_mix\n"
                "  1. (δ, λ) ← SPECTRAL-GAP(P)\n"
                "  2. t_mix ← ⌈log(1/ε) / log(1/λ)⌉\n"
                "  3. return t_mix\n"
                "  \n"
                "  Guarantee: λ^t_mix < ε (Theorem 3.8)\n"
                "  By Theorem A: |(P^t f)(x)| ≤ ε · ‖f‖₂ for t ≥ t_mix"
            ),
            "code": "# See algorithms.py mixing_time() function"
        }
    ],
    "visualizations": [
        {
            "name": "Spectral Mixing Decay (Theorem A)",
            "data": images.get('spectral_mixing', '')
        },
        {
            "name": "Correlation Decay Along Walk (Theorem B)",
            "data": images.get('correlation_decay', '')
        },
        {
            "name": "Seed Length Bound 3^n ≤ 4^n (Theorem C)",
            "data": images.get('seed_length', '')
        },
        {
            "name": "Eigenvalue Spectra: Impact of Graph Connectivity",
            "data": images.get('eigenvalue_spectrum', '')
        }
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json written ({len(json.dumps(package))} chars)")


#!/usr/bin/env python3
"""
Expander Walk Derandomization — Concrete Numerical Demonstrations

This script demonstrates the core theorems with concrete numerical examples:
1. Spectral mixing: how P^t f decays pointwise
2. Correlation decay: how ⟨f, P^t g⟩ vanishes exponentially
3. Seed length: how 3^n fits in 2n bits
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ============================================================
# Demo 1: Spectral mixing on a cycle graph
# ============================================================
def demo_spectral_mixing():
    """
    Demonstrate Theorem A: pointwise decay of P^t f.
    We use the cycle graph C_20 with lazy random walk.
    """
    n = 20
    # Lazy random walk on cycle: P = (I + A/2) / 2
    # where A is the adjacency of the cycle (each vertex connects to ±1)
    P = np.zeros((n, n))
    for i in range(n):
        P[i, i] = 0.5  # stay
        P[i, (i + 1) % n] = 0.25  # right
        P[i, (i - 1) % n] = 0.25  # left

    # Mean-zero observable: f(x) = cos(2πx/n)
    f = np.array([np.cos(2 * np.pi * k / n) for k in range(n)])
    f -= f.mean()  # ensure exactly mean zero

    l2_f = np.sqrt(np.sum(f**2))

    # Compute P^t f for various t
    max_t = 50
    pointwise_vals = []
    l2_norms = []
    for t in range(max_t + 1):
        Pt_f = np.linalg.matrix_power(P, t) @ f
        pointwise_vals.append(abs(Pt_f[0]))  # |P^t f at vertex 0|
        l2_norms.append(np.sqrt(np.sum(Pt_f**2)))

    # Second eigenvalue of lazy walk on cycle
    eigenvalues = np.sort(np.linalg.eigvalsh(P))[::-1]
    lam = max(abs(eigenvalues[1]), abs(eigenvalues[-1]))

    print("=" * 60)
    print("Demo 1: Spectral Mixing on Cycle C_20")
    print("=" * 60)
    print(f"State space size:    n = {n}")
    print(f"Second eigenvalue:   λ = {lam:.6f}")
    print(f"Spectral gap:        δ = {1 - lam:.6f}")
    print(f"L² norm of f:        ‖f‖₂ = {l2_f:.6f}")
    print()
    print(f"{'t':>4}  {'|P^t f(0)|':>12}  {'λ^t · ‖f‖₂':>12}  {'Bound holds?':>14}")
    print("-" * 50)
    for t in [0, 1, 5, 10, 20, 30, 50]:
        actual = pointwise_vals[t]
        bound = lam**t * l2_f
        ok = "✓" if actual <= bound + 1e-10 else "✗"
        print(f"{t:4d}  {actual:12.8f}  {bound:12.8f}  {ok:>14}")

    # Plot
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ts = np.arange(max_t + 1)
    ax1.semilogy(ts, pointwise_vals, 'b-', linewidth=2, label='|P^t f(0)|')
    ax1.semilogy(ts, [lam**t * l2_f for t in ts], 'r--', linewidth=2, label='λ^t · ‖f‖₂')
    ax1.set_xlabel('Walk length t', fontsize=12)
    ax1.set_ylabel('Value', fontsize=12)
    ax1.set_title('Theorem A: Pointwise Mixing Decay', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    ax2.semilogy(ts, l2_norms, 'b-', linewidth=2, label='‖P^t f‖₂')
    ax2.semilogy(ts, [lam**t * l2_f for t in ts], 'r--', linewidth=2, label='λ^t · ‖f‖₂')
    ax2.set_xlabel('Walk length t', fontsize=12)
    ax2.set_ylabel('L² norm', fontsize=12)
    ax2.set_title('L² Contraction', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('spectral_mixing.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n→ Saved spectral_mixing.png")
    return lam


# ============================================================
# Demo 2: Correlation decay
# ============================================================
def demo_correlation_decay():
    """
    Demonstrate Theorem B: correlation decay ⟨f, P^t g⟩.
    """
    n = 30
    # Expander-like: Cayley graph on Z/nZ with generators {1, 3, 7}
    P = np.zeros((n, n))
    generators = [1, 3, 7]
    for i in range(n):
        P[i, i] = 0.25  # lazy
        for g in generators:
            P[i, (i + g) % n] += 0.75 / (2 * len(generators))
            P[i, (i - g) % n] += 0.75 / (2 * len(generators))

    # Two mean-zero observables
    f = np.array([np.sin(2 * np.pi * k / n) for k in range(n)])
    g = np.array([np.cos(4 * np.pi * k / n) for k in range(n)])
    f -= f.mean()
    g -= g.mean()

    l2_f = np.sqrt(np.sum(f**2))
    l2_g = np.sqrt(np.sum(g**2))

    eigenvalues = np.sort(np.linalg.eigvalsh(P))[::-1]
    lam = max(abs(eigenvalues[1]), abs(eigenvalues[-1]))

    max_t = 60
    correlations = []
    for t in range(max_t + 1):
        Pt_g = np.linalg.matrix_power(P, t) @ g
        corr = abs(np.sum(f * Pt_g))
        correlations.append(corr)

    print("\n" + "=" * 60)
    print("Demo 2: Correlation Decay")
    print("=" * 60)
    print(f"State space:    Z/{n}Z with generators {{1, 3, 7}}")
    print(f"Second eigenvalue: λ = {lam:.6f}")
    print(f"‖f‖₂ = {l2_f:.4f}, ‖g‖₂ = {l2_g:.4f}")
    print()
    print(f"{'t':>4}  {'|⟨f, P^t g⟩|':>14}  {'‖f‖₂ · λ^t · ‖g‖₂':>20}  {'OK?':>4}")
    print("-" * 50)
    for t in [0, 1, 5, 10, 20, 40, 60]:
        actual = correlations[t]
        bound = l2_f * lam**t * l2_g
        ok = "✓" if actual <= bound + 1e-10 else "✗"
        print(f"{t:4d}  {actual:14.8f}  {bound:20.8f}  {ok:>4}")

    fig, ax = plt.subplots(figsize=(8, 5))
    ts = np.arange(max_t + 1)
    ax.semilogy(ts, correlations, 'b-', linewidth=2, label='|⟨f, P^t g⟩|')
    ax.semilogy(ts, [l2_f * lam**t * l2_g for t in ts], 'r--', linewidth=2,
                label='‖f‖₂ · λ^t · ‖g‖₂')
    ax.set_xlabel('Walk length t', fontsize=12)
    ax.set_ylabel('Correlation', fontsize=12)
    ax.set_title('Theorem B: Correlation Decay Along Expander Walk', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('correlation_decay.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n→ Saved correlation_decay.png")


# ============================================================
# Demo 3: Seed length bounds
# ============================================================
def demo_seed_length():
    """
    Demonstrate Theorem C: 3^n ≤ 2^(2n), linear seed length.
    """
    print("\n" + "=" * 60)
    print("Demo 3: Seed Length Bounds")
    print("=" * 60)
    print(f"\n{'n':>4}  {'3^n':>15}  {'2^(2n)':>15}  {'⌈log₂(3^n)⌉':>12}  {'2n':>4}  {'OK?':>4}")
    print("-" * 60)
    for n in range(1, 21):
        three_n = 3**n
        two_2n = 2**(2*n)
        log_bits = int(np.ceil(np.log2(three_n))) if three_n > 0 else 0
        ok = "✓" if three_n <= two_2n else "✗"
        print(f"{n:4d}  {three_n:15d}  {two_2n:15d}  {log_bits:12d}  {2*n:4d}  {ok:>4}")

    # Plot
    ns = np.arange(1, 25)
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.semilogy(ns, [3**n for n in ns], 'b-o', linewidth=2, markersize=4, label='3^n')
    ax.semilogy(ns, [4**n for n in ns], 'r--s', linewidth=2, markersize=4, label='4^n = 2^(2n)')
    ax.set_xlabel('n', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Theorem C: 3^n ≤ 4^n — Linear Seed Length', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('seed_length.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n→ Saved seed_length.png")
    print(f"\nlog₂(3) = {np.log2(3):.10f} < 2  ✓")
    print("Therefore ⌈log₂(3^n)⌉ ≤ 2n for all n ≥ 1.")


# ============================================================
# Demo 4: Eigenvalue spectrum visualization
# ============================================================
def demo_eigenvalue_spectrum():
    """
    Show the spectrum of different expander-like graphs,
    highlighting the spectral gap.
    """
    print("\n" + "=" * 60)
    print("Demo 4: Eigenvalue Spectra")
    print("=" * 60)

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    graphs = [
        ("Cycle C_30", 30, [1]),
        ("C_30 + {3}", 30, [1, 3]),
        ("C_30 + {3,7}", 30, [1, 3, 7]),
    ]

    for ax, (name, n, gens) in zip(axes, graphs):
        P = np.zeros((n, n))
        for i in range(n):
            P[i, i] = 0.25
            for g_val in gens:
                P[i, (i + g_val) % n] += 0.75 / (2 * len(gens))
                P[i, (i - g_val) % n] += 0.75 / (2 * len(gens))

        eigs = np.sort(np.linalg.eigvalsh(P))[::-1]
        gap = 1 - max(abs(eigs[1]), abs(eigs[-1]))

        ax.bar(range(len(eigs)), eigs, color='steelblue', alpha=0.7)
        ax.axhline(y=eigs[1], color='red', linestyle='--', alpha=0.7,
                   label=f'λ₂ = {eigs[1]:.3f}')
        ax.set_title(f'{name}\ngap = {gap:.4f}', fontsize=12)
        ax.set_xlabel('Index', fontsize=10)
        ax.set_ylabel('Eigenvalue', fontsize=10)
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)

        print(f"{name}: spectral gap = {gap:.6f}, λ₂ = {eigs[1]:.6f}")

    plt.tight_layout()
    plt.savefig('eigenvalue_spectrum.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n→ Saved eigenvalue_spectrum.png")


if __name__ == "__main__":
    demo_spectral_mixing()
    demo_correlation_decay()
    demo_seed_length()
    demo_eigenvalue_spectrum()
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)
