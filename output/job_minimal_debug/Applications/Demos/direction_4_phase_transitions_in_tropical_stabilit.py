"""
Applications of Tropical Phase Transition Theory

Demonstrates real-world applications of the tropical margin framework:
1. Kernel matrix stability certification
2. Feature interaction analysis in random feature models
3. Network weight stability monitoring
"""

import numpy as np


# ── Inline core functions ─────────────────────────────────────────────────

def trop_margin(W):
    n = W.shape[0]
    min_val = float('inf')
    for i in range(n):
        for j in range(n):
            if i != j:
                val = 2 * W[i, j] - W[i, i] - W[j, j]
                if val < min_val:
                    min_val = val
    return min_val


def trop_margin_with_witness(W):
    n = W.shape[0]
    min_val = float('inf')
    witness = (0, 1)
    for i in range(n):
        for j in range(n):
            if i != j:
                val = 2 * W[i, j] - W[i, i] - W[j, j]
                if val < min_val:
                    min_val = val
                    witness = (i, j)
    return min_val, witness


def entry_sup_norm(W):
    return float(np.max(np.abs(W)))


def mean_model(n, mu_diag, mu_off):
    M = np.full((n, n), mu_off, dtype=float)
    np.fill_diagonal(M, mu_diag)
    return M


# ── Application 1: Kernel Matrix Stability ────────────────────────────────

def kernel_stability_analysis():
    """Analyze stability of kernel matrices under noise.

    In machine learning, kernel matrices K[i,j] = k(x_i, x_j) are symmetric
    and encode pairwise similarities. The tropical margin measures whether
    off-diagonal interactions dominate diagonal self-similarities — a key
    condition for well-conditioned learning.
    """
    print("=" * 60)
    print("Application 1: Kernel Matrix Stability")
    print("=" * 60)

    rng = np.random.default_rng(42)
    n = 10

    # RBF kernel with varying bandwidth
    X = rng.normal(0, 1, (n, 3))
    for gamma in [0.1, 0.5, 1.0, 2.0, 5.0]:
        dists = np.sum((X[:, None, :] - X[None, :, :]) ** 2, axis=2)
        K = np.exp(-gamma * dists)
        margin = trop_margin(K)
        val, (wi, wj) = trop_margin_with_witness(K)
        print(f"  γ = {gamma:4.1f}: tropMargin = {margin:8.4f}, "
              f"witness = ({wi},{wj})")

    print("\nInterpretation: Smaller γ (broader kernel) yields more positive")
    print("margins, indicating more stable feature interactions.")


# ── Application 2: Random Feature Model Stability ────────────────────────

def random_feature_stability():
    """Test tropical stability in random feature models.

    Random feature models use W = Φ^T Φ / m where Φ is a random feature
    matrix. The tropical margin predicts whether the model is in a
    'well-conditioned' regime.
    """
    print("\n" + "=" * 60)
    print("Application 2: Random Feature Model Stability")
    print("=" * 60)

    rng = np.random.default_rng(55)
    n = 8  # number of data points

    for m in [5, 10, 20, 50, 100]:
        # Random features: Φ is m × n
        Phi = rng.normal(0, 1, (m, n))
        W = Phi.T @ Phi / m  # Gram matrix

        margin = trop_margin(W)
        diag_mean = np.mean(np.diag(W))
        off_diag = W[np.triu_indices(n, k=1)]
        off_mean = np.mean(off_diag)

        print(f"  m = {m:3d}: tropMargin = {margin:8.4f}, "
              f"diag_mean = {diag_mean:.3f}, off_mean = {off_mean:.3f}")

    print("\nInterpretation: As m/n grows, the Gram matrix concentrates and")
    print("the tropical margin becomes increasingly negative (diagonal-dominant).")


# ── Application 3: Network Weight Monitoring ─────────────────────────────

def network_weight_monitoring():
    """Monitor tropical stability during simulated training.

    Tracks how the tropical margin evolves as a weight matrix is
    perturbed — analogous to SGD updates in neural network training.
    """
    print("\n" + "=" * 60)
    print("Application 3: Network Weight Stability Monitoring")
    print("=" * 60)

    rng = np.random.default_rng(88)
    n = 6

    # Start with a stable configuration
    W = mean_model(n, 0, 2)
    print(f"  Initial: tropMargin = {trop_margin(W):.4f}")

    # Simulate "training" with increasing perturbation
    for step in range(1, 11):
        noise = rng.normal(0, 0.3 * step, (n, n))
        noise = (noise + noise.T) / 2
        W_perturbed = W + noise

        margin = trop_margin(W_perturbed)
        noise_norm = entry_sup_norm(noise)
        certified_lb = 2 * 2 - 4 * noise_norm  # 2*(μ_off - μ_diag) - 4*ε

        print(f"  Step {step:2d}: tropMargin = {margin:8.4f}, "
              f"‖noise‖∞ = {noise_norm:.3f}, "
              f"certified_lb = {certified_lb:8.4f}, "
              f"{'STABLE' if margin >= 0 else 'UNSTABLE'}")


# ── Application 4: Signal-to-Noise Threshold Detection ───────────────────

def signal_noise_threshold():
    """Find the critical signal-to-noise ratio for tropical stability.

    Uses binary search to find the noise level at which P(tropMargin ≥ 0)
    crosses 0.5, and compares with the theoretical prediction.
    """
    print("\n" + "=" * 60)
    print("Application 4: Signal-to-Noise Threshold Detection")
    print("=" * 60)

    rng = np.random.default_rng(101)

    for n in [5, 8, 12]:
        mu_off = 3.0
        mu_diag = 0.0
        signal = mu_off - mu_diag  # = 3.0

        # Binary search for critical sigma
        sigma_lo, sigma_hi = 0.1, 10.0
        for _ in range(20):
            sigma_mid = (sigma_lo + sigma_hi) / 2
            count = 0
            for _ in range(500):
                W = mean_model(n, mu_diag, mu_off)
                noise = rng.normal(0, sigma_mid, (n, n))
                noise = (noise + noise.T) / 2
                if trop_margin(W + noise) >= 0:
                    count += 1
            p = count / 500
            if p > 0.5:
                sigma_lo = sigma_mid
            else:
                sigma_hi = sigma_mid

        sigma_crit = (sigma_lo + sigma_hi) / 2
        scaled_ratio = signal / (sigma_crit * np.sqrt(np.log(n)))
        print(f"  n = {n:2d}: σ_crit ≈ {sigma_crit:.3f}, "
              f"signal/(σ·√log n) ≈ {scaled_ratio:.3f}")

    print("\nIf the scaled ratio is approximately constant across n,")
    print("this supports the √log n scaling conjecture.")


# ── Main ──────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    kernel_stability_analysis()
    random_feature_stability()
    network_weight_monitoring()
    signal_noise_threshold()
    print("\n✓ All applications completed successfully.")


"""
Demo: Phase Transitions in Tropical Stability

Generates symmetric Gaussian matrices with separate diagonal/off-diagonal means,
computes empirical P(tropMargin ≥ 0), plots probability against the scaled parameter
(μ_off - μ_diag) / (σ √log n), and displays witness quadruples.

Demonstrates the deterministic certified lower bound from the formal theorem package.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ── Inline implementations (self-contained) ──────────────────────────────

def trop_margin(W):
    """Tropical margin: min_{i≠j} (2*W[i,j] - W[i,i] - W[j,j])."""
    n = W.shape[0]
    min_val = float('inf')
    for i in range(n):
        for j in range(n):
            if i != j:
                val = 2 * W[i, j] - W[i, i] - W[j, j]
                if val < min_val:
                    min_val = val
    return min_val


def trop_margin_with_witness(W):
    """Compute tropical margin with witness pair (i, j)."""
    n = W.shape[0]
    min_val = float('inf')
    witness = (0, 1)
    for i in range(n):
        for j in range(n):
            if i != j:
                val = 2 * W[i, j] - W[i, i] - W[j, j]
                if val < min_val:
                    min_val = val
                    witness = (i, j)
    return min_val, witness


def mean_model(n, mu_diag, mu_off):
    M = np.full((n, n), mu_off, dtype=float)
    np.fill_diagonal(M, mu_diag)
    return M


def generate_symmetric_gaussian(n, mu_diag, mu_off, sigma, rng):
    W = rng.normal(0, sigma, (n, n))
    W = (W + W.T) / np.sqrt(2)
    return mean_model(n, mu_diag, mu_off) + W


# ── 1. Empirical phase transition curves ─────────────────────────────────

def run_phase_transition_experiment():
    """Plot P(tropMargin ≥ 0) vs scaled parameter for multiple n."""
    print("=" * 60)
    print("Phase Transition in Tropical Stability")
    print("=" * 60)

    ns = [5, 10, 20]
    sigma = 1.0
    num_samples = 2000
    num_points = 30
    rng = np.random.default_rng(42)

    # Scaled parameter range
    x_range = np.linspace(-2.0, 4.0, num_points)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    colors = ['#2196F3', '#FF5722', '#4CAF50']

    for idx, n in enumerate(ns):
        log_n = np.log(n)
        probs = []

        for x in x_range:
            mu_diff = x * sigma * np.sqrt(log_n)
            mu_diag = 0
            mu_off = mu_diff

            count = 0
            for _ in range(num_samples):
                W = generate_symmetric_gaussian(n, mu_diag, mu_off, sigma, rng)
                if trop_margin(W) >= 0:
                    count += 1
            probs.append(count / num_samples)

        ax1.plot(x_range, probs, 'o-', color=colors[idx], label=f'n = {n}',
                 markersize=3, linewidth=1.5)

        # Also plot certified lower bound
        cert_probs = []
        for x in x_range:
            mu_diff = x * sigma * np.sqrt(log_n)
            # Certified bound: 2*mu_diff - 4*sigma*sqrt(2*log(n^2)) approx
            # Noise sup-norm concentrates around sigma*sqrt(2*log(n^2))
            noise_scale = sigma * np.sqrt(2 * np.log(n * n + 1))
            cert = 2 * mu_diff - 4 * noise_scale
            cert_probs.append(1.0 if cert > 0 else 0.0)
        ax2.plot(x_range, cert_probs, '--', color=colors[idx],
                 label=f'n = {n} (certified)', linewidth=2)

    ax1.set_xlabel(r'$(\mu_{off} - \mu_{diag}) / (\sigma \sqrt{\log n})$', fontsize=12)
    ax1.set_ylabel(r'$P(\mathrm{tropMargin}(W) \geq 0)$', fontsize=12)
    ax1.set_title('Monte Carlo: Tropical Stability Probability', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(-0.05, 1.05)

    ax2.set_xlabel(r'$(\mu_{off} - \mu_{diag}) / (\sigma \sqrt{\log n})$', fontsize=12)
    ax2.set_ylabel('Certified stable?', fontsize=12)
    ax2.set_title('Deterministic Certified Lower Bound', fontsize=13)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(-0.05, 1.05)

    plt.tight_layout()
    plt.savefig('phase_transition_curves.png', dpi=150, bbox_inches='tight')
    print("Saved: phase_transition_curves.png")
    plt.close()


# ── 2. Witness quadruple display ─────────────────────────────────────────

def show_witness_examples():
    """Show witness pairs when instability occurs."""
    print("\n" + "=" * 60)
    print("Witness Extraction Examples")
    print("=" * 60)

    rng = np.random.default_rng(123)
    n = 6

    # Unstable case
    W = generate_symmetric_gaussian(n, 0, -0.5, 1.0, rng)
    val, (wi, wj) = trop_margin_with_witness(W)
    print(f"\nUnstable matrix (n={n}, μ_diag=0, μ_off=-0.5, σ=1):")
    print(f"  tropMargin = {val:.4f}")
    print(f"  Witness pair: ({wi}, {wj})")
    print(f"  W[{wi},{wj}] = {W[wi, wj]:.4f}")
    print(f"  W[{wi},{wi}] = {W[wi, wi]:.4f}")
    print(f"  W[{wj},{wj}] = {W[wj, wj]:.4f}")
    print(f"  2*W[{wi},{wj}] - W[{wi},{wi}] - W[{wj},{wj}] = {val:.4f}")

    # Stable case
    W2 = generate_symmetric_gaussian(n, 0, 3, 0.5, rng)
    val2, (wi2, wj2) = trop_margin_with_witness(W2)
    print(f"\nStable matrix (n={n}, μ_diag=0, μ_off=3, σ=0.5):")
    print(f"  tropMargin = {val2:.4f}")
    print(f"  Witness pair: ({wi2}, {wj2})")


# ── 3. Certified bound comparison ────────────────────────────────────────

def certified_bound_comparison():
    """Compare Monte Carlo vs certified lower bound."""
    print("\n" + "=" * 60)
    print("Certified Bound vs Monte Carlo")
    print("=" * 60)

    n = 10
    sigma = 1.0
    rng = np.random.default_rng(99)

    print(f"\nn = {n}, σ = {sigma}")
    print(f"{'μ_off':>8} {'Certified':>12} {'MC margin':>12} {'MC P(≥0)':>10}")
    print("-" * 46)

    for mu_off in [0.0, 1.0, 2.0, 3.0, 4.0, 5.0]:
        mu_diag = 0.0
        # Certified bound
        # Expected noise sup-norm ~ sigma * sqrt(2 * log(n^2))
        expected_noise = sigma * np.sqrt(2 * np.log(n * n + 1))
        cert = 2 * (mu_off - mu_diag) - 4 * expected_noise

        # Monte Carlo
        margins = []
        for _ in range(1000):
            W = generate_symmetric_gaussian(n, mu_diag, mu_off, sigma, rng)
            margins.append(trop_margin(W))
        mc_mean = np.mean(margins)
        mc_prob = np.mean([m >= 0 for m in margins])

        print(f"{mu_off:8.1f} {cert:12.3f} {mc_mean:12.3f} {mc_prob:10.3f}")


# ── 4. Mean model verification ───────────────────────────────────────────

def verify_mean_model():
    """Verify tropMargin(meanModel) = 2*(μ_off - μ_diag)."""
    print("\n" + "=" * 60)
    print("Mean Model Verification (Theorem 4)")
    print("=" * 60)

    for n in [3, 5, 10, 20]:
        for mu_diag, mu_off in [(0, 1), (1, 3), (-1, 2), (5, 5)]:
            M = mean_model(n, mu_diag, mu_off)
            computed = trop_margin(M)
            expected = 2 * (mu_off - mu_diag)
            assert abs(computed - expected) < 1e-10, \
                f"FAIL: n={n}, μd={mu_diag}, μo={mu_off}: {computed} ≠ {expected}"

    print("All mean model tests passed ✓")
    print("tropMargin(meanModel(n, μ_d, μ_o)) = 2*(μ_o - μ_d) verified for multiple (n, μ_d, μ_o)")


# ── 5. Monotonicity verification ─────────────────────────────────────────

def verify_monotonicity():
    """Verify ferromagnetic monotonicity (Theorem 5)."""
    print("\n" + "=" * 60)
    print("Monotonicity Verification (Theorem 5)")
    print("=" * 60)

    rng = np.random.default_rng(77)
    n = 8
    passed = 0
    total = 100

    for _ in range(total):
        W = rng.normal(0, 1, (n, n))
        W = (W + W.T) / 2

        # Create W' by increasing off-diagonal, decreasing diagonal
        delta_diag = rng.uniform(0, 1, n)
        delta_off = rng.uniform(0, 1, (n, n))
        delta_off = (delta_off + delta_off.T) / 2

        W_prime = W.copy()
        for i in range(n):
            W_prime[i, i] -= delta_diag[i]  # decrease diagonal
            for j in range(n):
                if i != j:
                    W_prime[i, j] += delta_off[i, j]  # increase off-diagonal

        m1 = trop_margin(W)
        m2 = trop_margin(W_prime)
        if m1 <= m2 + 1e-10:
            passed += 1

    print(f"Monotonicity test: {passed}/{total} passed")
    assert passed == total, "Monotonicity violation detected!"
    print("Ferromagnetic monotonicity verified ✓")


# ── Main ──────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    verify_mean_model()
    verify_monotonicity()
    show_witness_examples()
    certified_bound_comparison()
    run_phase_transition_experiment()
    print("\n✓ All demos completed successfully.")


"""
Visualization 3: Lipschitz Stability of the Tropical Margin

Demonstrates the Lipschitz bound |tropMargin(W) - tropMargin(W')| ≤ 4·‖W-W'‖∞
by generating random perturbations and plotting actual margin differences
vs the 4·‖perturbation‖∞ bound. All points should lie below the diagonal,
confirming the formally verified Lipschitz constant of 4.

Also shows the signal/noise decomposition theorem: the margin of the
perturbed matrix is bounded below by signal minus 4·noise.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def trop_margin(W):
    n = W.shape[0]
    min_val = float('inf')
    for i in range(n):
        for j in range(n):
            if i != j:
                val = 2 * W[i, j] - W[i, i] - W[j, j]
                if val < min_val:
                    min_val = val
    return min_val


def entry_sup_norm(W):
    return float(np.max(np.abs(W)))


def mean_model(n, mu_diag, mu_off):
    M = np.full((n, n), mu_off, dtype=float)
    np.fill_diagonal(M, mu_diag)
    return M


rng = np.random.default_rng(42)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# ── Left: Lipschitz bound verification ──

n = 8
num_trials = 300
perturbation_norms = []
margin_diffs = []
bounds = []

W_base = rng.normal(0, 1, (n, n))
W_base = (W_base + W_base.T) / 2
margin_base = trop_margin(W_base)

for _ in range(num_trials):
    scale = rng.uniform(0, 2)
    delta = rng.normal(0, scale, (n, n))
    delta = (delta + delta.T) / 2

    W_pert = W_base + delta
    margin_pert = trop_margin(W_pert)

    pert_norm = entry_sup_norm(delta)
    margin_diff = abs(margin_base - margin_pert)

    perturbation_norms.append(pert_norm)
    margin_diffs.append(margin_diff)
    bounds.append(4 * pert_norm)

ax1.scatter(perturbation_norms, margin_diffs, s=8, alpha=0.5,
            color='#1976D2', label='Actual |Δ margin|')
max_x = max(perturbation_norms) * 1.05
ax1.plot([0, max_x], [0, 4 * max_x], 'r-', linewidth=2,
         label='4·‖ΔW‖∞ bound', alpha=0.8)
ax1.set_xlabel('‖W − W\'‖∞', fontsize=13)
ax1.set_ylabel('|tropMargin(W) − tropMargin(W\')|', fontsize=13)
ax1.set_title('Lipschitz Bound Verification\n(All points below red line)', fontsize=13)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.25)

# ── Right: Signal/noise decomposition ──

n = 10
mu_off_vals = [2.0, 3.0, 4.0]
noise_scales = np.linspace(0, 3, 25)

for mu_off in mu_off_vals:
    signal = 2 * mu_off  # tropMargin of meanModel(n, 0, mu_off)
    actual_margins = []
    certified_lbs = []

    for sigma in noise_scales:
        margins_sample = []
        for _ in range(200):
            noise = rng.normal(0, sigma, (n, n))
            noise = (noise + noise.T) / np.sqrt(2)
            W = mean_model(n, 0, mu_off) + noise
            margins_sample.append(trop_margin(W))

        actual_margins.append(np.mean(margins_sample))
        # Certified: signal - 4 * expected_noise_supnorm
        # E[sup_norm] ≈ sigma * sqrt(2 * log(n^2))
        expected_noise = sigma * np.sqrt(2 * np.log(n * n + 1))
        certified_lbs.append(signal - 4 * expected_noise)

    ax2.plot(noise_scales, actual_margins, '-', linewidth=2,
             label=f'MC mean (μ_off={mu_off})')
    ax2.plot(noise_scales, certified_lbs, '--', linewidth=1.5, alpha=0.7,
             label=f'Certified (μ_off={mu_off})')

ax2.axhline(y=0, color='black', linestyle=':', alpha=0.5)
ax2.set_xlabel('Noise scale σ', fontsize=13)
ax2.set_ylabel('tropMargin', fontsize=13)
ax2.set_title('Signal/Noise Decomposition\n(Solid: MC, Dashed: Certified lower bound)', fontsize=13)
ax2.legend(fontsize=9, ncol=2)
ax2.grid(True, alpha=0.25)

plt.tight_layout()
plt.savefig('viz_lipschitz_stability.png', dpi=150, bbox_inches='tight')
print("Saved: viz_lipschitz_stability.png")


"""
Visualization 2: Tropical Margin Heatmap

Displays the tropical margin as a function of the two mean parameters
(μ_diag, μ_off) for a fixed matrix size, overlaid with the stability
boundary tropMargin = 0. Illustrates the deterministic theorem
tropMargin(meanModel) = 2*(μ_off - μ_diag).

The diagonal line μ_off = μ_diag is the exact phase boundary for the
mean model, with the stable region above and unstable region below.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import TwoSlopeNorm


def trop_margin(W):
    """Tropical margin: min_{i≠j} (2*W[i,j] - W[i,i] - W[j,j])."""
    n = W.shape[0]
    min_val = float('inf')
    for i in range(n):
        for j in range(n):
            if i != j:
                val = 2 * W[i, j] - W[i, i] - W[j, j]
                if val < min_val:
                    min_val = val
    return min_val


def mean_model(n, mu_diag, mu_off):
    M = np.full((n, n), mu_off, dtype=float)
    np.fill_diagonal(M, mu_diag)
    return M


# Compute margin grid
n = 8
res = 80
mu_diag_range = np.linspace(-3, 3, res)
mu_off_range = np.linspace(-3, 3, res)
Z = np.zeros((res, res))

for i, md in enumerate(mu_diag_range):
    for j, mo in enumerate(mu_off_range):
        Z[j, i] = 2 * (mo - md)  # exact formula from theorem

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: Deterministic margin heatmap
norm = TwoSlopeNorm(vmin=-8, vcenter=0, vmax=8)
im1 = ax1.pcolormesh(mu_diag_range, mu_off_range, Z, cmap='RdBu',
                      norm=norm, shading='auto')
ax1.contour(mu_diag_range, mu_off_range, Z, levels=[0],
            colors='black', linewidths=2)
ax1.plot([-3, 3], [-3, 3], 'k--', linewidth=1, alpha=0.5, label=r'$\mu_{off} = \mu_{diag}$')
fig.colorbar(im1, ax=ax1, label='tropMargin')
ax1.set_xlabel(r'$\mu_{\mathrm{diag}}$', fontsize=13)
ax1.set_ylabel(r'$\mu_{\mathrm{off}}$', fontsize=13)
ax1.set_title('Mean Model: tropMargin = 2(μ_off − μ_diag)', fontsize=13)
ax1.legend(fontsize=11)
ax1.set_aspect('equal')

# Right: Monte Carlo with noise
sigma = 1.0
rng = np.random.default_rng(42)
num_samples = 200
res2 = 40
mu_diag_range2 = np.linspace(-3, 3, res2)
mu_off_range2 = np.linspace(-3, 3, res2)
Z2 = np.zeros((res2, res2))

for i, md in enumerate(mu_diag_range2):
    for j, mo in enumerate(mu_off_range2):
        count = 0
        for _ in range(num_samples):
            noise = rng.normal(0, sigma, (n, n))
            noise = (noise + noise.T) / np.sqrt(2)
            W = mean_model(n, md, mo) + noise
            if trop_margin(W) >= 0:
                count += 1
        Z2[j, i] = count / num_samples

im2 = ax2.pcolormesh(mu_diag_range2, mu_off_range2, Z2, cmap='RdBu',
                      vmin=0, vmax=1, shading='auto')
ax2.contour(mu_diag_range2, mu_off_range2, Z2, levels=[0.5],
            colors='black', linewidths=2)
ax2.plot([-3, 3], [-3, 3], 'k--', linewidth=1, alpha=0.5)
fig.colorbar(im2, ax=ax2, label='P(tropMargin ≥ 0)')
ax2.set_xlabel(r'$\mu_{\mathrm{diag}}$', fontsize=13)
ax2.set_ylabel(r'$\mu_{\mathrm{off}}$', fontsize=13)
ax2.set_title(f'With Gaussian Noise (σ={sigma}, n={n})', fontsize=13)
ax2.set_aspect('equal')

plt.suptitle('Tropical Stability Phase Diagram', fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('viz_margin_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved: viz_margin_heatmap.png")


"""
Visualization 1: Phase Transition Curves in Tropical Stability

Plots the probability P(tropMargin ≥ 0) as a function of the scaled parameter
(μ_off - μ_diag) / (σ √log n) for multiple matrix sizes. The near-collapse
of curves supports the √log n scaling conjecture for the phase transition.

This visualizes the core prediction of the tropical phase transition theory:
there exists a sharp threshold separating stable (positive margin) from
unstable (negative margin) regimes, governed by a universal scaling law.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def trop_margin(W):
    """Tropical margin: min_{i≠j} (2*W[i,j] - W[i,i] - W[j,j])."""
    n = W.shape[0]
    min_val = float('inf')
    for i in range(n):
        for j in range(n):
            if i != j:
                val = 2 * W[i, j] - W[i, i] - W[j, j]
                if val < min_val:
                    min_val = val
    return min_val


def mean_model(n, mu_diag, mu_off):
    M = np.full((n, n), mu_off, dtype=float)
    np.fill_diagonal(M, mu_diag)
    return M


def generate_symmetric_gaussian(n, mu_diag, mu_off, sigma, rng):
    W = rng.normal(0, sigma, (n, n))
    W = (W + W.T) / np.sqrt(2)
    return mean_model(n, mu_diag, mu_off) + W


# Parameters
ns = [5, 10, 20]
sigma = 1.0
num_samples = 2000
num_points = 35
rng = np.random.default_rng(42)

x_range = np.linspace(-2.0, 5.0, num_points)

fig, ax = plt.subplots(figsize=(10, 7))

colors = ['#1976D2', '#E64A19', '#388E3C']
markers = ['o', 's', '^']

for idx, n in enumerate(ns):
    log_n = np.log(n)
    probs = []

    for x in x_range:
        mu_diff = x * sigma * np.sqrt(log_n)
        count = 0
        for _ in range(num_samples):
            W = generate_symmetric_gaussian(n, 0, mu_diff, sigma, rng)
            if trop_margin(W) >= 0:
                count += 1
        probs.append(count / num_samples)

    ax.plot(x_range, probs, marker=markers[idx], color=colors[idx],
            label=f'n = {n}', markersize=4, linewidth=2, alpha=0.85)

# Theoretical step function reference
ax.axvline(x=0, color='gray', linestyle=':', alpha=0.5, label='Signal = 0')
ax.axhline(y=0.5, color='gray', linestyle='--', alpha=0.3)

ax.set_xlabel(r'Scaled parameter $(\mu_{\mathrm{off}} - \mu_{\mathrm{diag}}) \;/\; (\sigma \sqrt{\log n})$',
              fontsize=14)
ax.set_ylabel(r'$\mathbb{P}(\mathrm{tropMargin}(W) \geq 0)$', fontsize=14)
ax.set_title('Phase Transition in Tropical Stability\nProbability of Positive Margin vs. Scaled Signal',
             fontsize=15)
ax.legend(fontsize=13, loc='lower right')
ax.grid(True, alpha=0.25)
ax.set_ylim(-0.05, 1.05)
ax.set_xlim(-2.5, 5.5)

plt.tight_layout()
plt.savefig('viz_phase_transition.png', dpi=150, bbox_inches='tight')
print("Saved: viz_phase_transition.png")
