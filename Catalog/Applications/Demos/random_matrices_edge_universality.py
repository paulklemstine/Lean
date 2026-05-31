#!/usr/bin/env python3
"""
demo.py — Numerical demonstrations of random matrix edge universality.

Demonstrates:
1. Catalan number growth and the ratio bound conjecture
2. Wigner semicircle law convergence
3. Tracy-Widom edge statistics
4. Moment method spectral bounds
5. Universality across different entry distributions
"""

import numpy as np
from algorithms import (
    catalan_number, catalan_ratio, wigner_density,
    semicircle_moment, generate_wigner_matrix,
    largest_eigenvalue_scaled, moment_method_spectral_bound,
    trace_shift_optimal, verify_catalan_ratio_bound,
)


def demo_catalan_numbers():
    """Demonstrate Catalan number properties."""
    print("=" * 60)
    print("DEMO 1: Catalan Numbers and the Ratio Bound")
    print("=" * 60)

    print("\nFirst 15 Catalan numbers:")
    for n in range(15):
        cn = catalan_number(n)
        print(f"  C_{n:2d} = {cn:>10d}")

    print("\nCatalan ratio C_{n+1}/C_n (should approach 4):")
    for n in [1, 2, 5, 10, 20, 50, 100]:
        r = catalan_ratio(n)
        print(f"  n={n:3d}: C_{n+1}/C_n = {r:.8f}  (4 - ratio = {4 - r:.8f})")

    print("\nVerifying ratio bound C_{n+1} < 4*C_n:")
    results = verify_catalan_ratio_bound(50)
    all_pass = all(r[2] for r in results)
    print(f"  All n=1..50 satisfy bound: {all_pass}")

    # Verify exact recurrence
    print("\nVerifying (n+2)*C_{n+1} = (4n+2)*C_n:")
    for n in range(20):
        cn = catalan_number(n)
        cn1 = catalan_number(n + 1)
        lhs = (n + 2) * cn1
        rhs = (4 * n + 2) * cn
        assert lhs == rhs, f"Failed at n={n}"
    print("  Verified for n = 0..19 ✓")


def demo_semicircle_law():
    """Demonstrate convergence to the Wigner semicircle law."""
    print("\n" + "=" * 60)
    print("DEMO 2: Wigner Semicircle Law Convergence")
    print("=" * 60)

    np.random.seed(42)

    for n in [50, 200, 1000]:
        num_trials = 100
        all_eigs = []
        for _ in range(num_trials):
            W = generate_wigner_matrix(n, "gaussian")
            eigs = np.linalg.eigvalsh(W)
            all_eigs.extend(eigs.tolist())

        all_eigs = np.array(all_eigs)
        print(f"\n  n = {n}, {num_trials} trials, {len(all_eigs)} eigenvalues:")
        print(f"    Mean: {np.mean(all_eigs):.6f} (should be ~0)")
        print(f"    Std:  {np.std(all_eigs):.6f}")
        print(f"    Min:  {np.min(all_eigs):.6f}")
        print(f"    Max:  {np.max(all_eigs):.6f}")

        # Check moments against Catalan numbers
        moments = []
        for k in range(1, 5):
            emp_moment = np.mean(all_eigs ** (2 * k))
            cat = catalan_number(k)
            moments.append((2 * k, emp_moment, cat))
        print(f"    Moment comparison (m_2k vs C_k):")
        for mk, emp, cat in moments:
            print(f"      m_{mk} = {emp:.4f}, C_{mk//2} = {cat}")


def demo_edge_universality():
    """Demonstrate Tracy-Widom edge statistics."""
    print("\n" + "=" * 60)
    print("DEMO 3: Edge Universality - Tracy-Widom Statistics")
    print("=" * 60)

    np.random.seed(123)
    n = 500
    num_trials = 1000

    distributions = ["gaussian", "bernoulli", "uniform"]

    for dist in distributions:
        scaled_max = []
        for _ in range(num_trials):
            W = generate_wigner_matrix(n, dist)
            s = largest_eigenvalue_scaled(W)
            scaled_max.append(s)

        scaled_max = np.array(scaled_max)
        print(f"\n  Distribution: {dist}")
        print(f"    n = {n}, {num_trials} trials")
        print(f"    Mean of n^(2/3)(λ_max/√n - 2): {np.mean(scaled_max):.4f}")
        print(f"    Std:  {np.std(scaled_max):.4f}")
        print(f"    Median: {np.median(scaled_max):.4f}")
        print(f"    Skewness: {float(np.mean(((scaled_max - np.mean(scaled_max))/np.std(scaled_max))**3)):.4f}")
        # TW mean ≈ -1.77, TW std ≈ 0.81
        print(f"    (Tracy-Widom: mean ≈ -1.77, std ≈ 0.81)")


def demo_moment_method():
    """Demonstrate the moment method for spectral bounds."""
    print("\n" + "=" * 60)
    print("DEMO 4: Moment Method Spectral Bounds")
    print("=" * 60)

    np.random.seed(456)
    n = 100
    W = generate_wigner_matrix(n, "gaussian")

    true_spectral_radius = np.max(np.abs(np.linalg.eigvalsh(W)))
    print(f"\n  n = {n}")
    print(f"  True spectral radius: {true_spectral_radius:.6f}")

    print(f"  Moment method bounds (tighter with higher k):")
    for k in [1, 2, 4, 8, 16]:
        bound = moment_method_spectral_bound(W, k)
        print(f"    k = {k:2d}: bound = {bound:.6f}  (ratio = {bound/true_spectral_radius:.4f})")

    # Trace shift demonstration
    c_opt, min_trace = trace_shift_optimal(W)
    print(f"\n  Optimal centering: c = {c_opt:.6f}")
    print(f"  tr(A²) = {np.trace(W @ W):.4f}")
    print(f"  tr((A-cI)²) = {min_trace:.4f}")
    print(f"  Reduction: {(1 - min_trace/np.trace(W@W))*100:.2f}%")


def demo_trace_identities():
    """Verify trace identities from the formalization."""
    print("\n" + "=" * 60)
    print("DEMO 5: Verified Trace Identities")
    print("=" * 60)

    np.random.seed(789)
    n = 50
    A = np.random.randn(n, n)
    A = (A + A.T) / 2  # Symmetrize

    # 1. Frobenius norm = tr(AAᵀ)
    frob_sq = np.sum(A**2)
    trace_aat = np.trace(A @ A.T)
    print(f"\n  Frobenius ||A||² = {frob_sq:.6f}")
    print(f"  tr(AAᵀ) = {trace_aat:.6f}")
    print(f"  Match: {np.isclose(frob_sq, trace_aat)}")

    # 2. For symmetric A, AAᵀ = A²
    diff = np.max(np.abs(A @ A.T - A @ A))
    print(f"\n  max|AAᵀ - A²| = {diff:.2e} (should be ~0 for symmetric A)")

    # 3. tr(A²) ≥ 0
    trace_sq = np.trace(A @ A)
    print(f"\n  tr(A²) = {trace_sq:.6f} ≥ 0: {trace_sq >= -1e-10}")

    # 4. Trace shift formula
    c = 1.5
    lhs = np.trace((A - c * np.eye(n)) @ (A - c * np.eye(n)))
    rhs = np.trace(A @ A) - 2 * c * np.trace(A) + c**2 * n
    print(f"\n  tr((A-cI)²) = {lhs:.6f}")
    print(f"  tr(A²) - 2c·tr(A) + c²n = {rhs:.6f}")
    print(f"  Match: {np.isclose(lhs, rhs)}")

    # 5. Projection kernel density
    print(f"\n  Projection kernel test:")
    rank = 10
    V = np.random.randn(n, rank)
    Q, _ = np.linalg.qr(V)
    Q = Q[:, :rank]
    K = Q @ Q.T  # Projection kernel

    print(f"    K² ≈ K: {np.allclose(K @ K, K, atol=1e-10)}")
    print(f"    tr(K) = {np.trace(K):.4f} ≈ rank = {rank}")
    print(f"    All K_ii ≥ 0: {np.all(np.diag(K) >= -1e-10)}")


if __name__ == "__main__":
    demo_catalan_numbers()
    demo_semicircle_law()
    demo_edge_universality()
    demo_moment_method()
    demo_trace_identities()
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Catalan Number Growth and Ratio Convergence

Shows the exponential growth of Catalan numbers and the
convergence of C_{n+1}/C_n → 4.
"""

import numpy as np
import matplotlib.pyplot as plt


def catalan_number(n):
    """Compute C_n using the recurrence (n+2)*C_{n+1} = (4n+2)*C_n."""
    if n == 0:
        return 1
    c = 1
    for k in range(n):
        c = c * (4 * k + 2) // (k + 2)
    return c


def main():
    max_n = 30
    ns = list(range(max_n + 1))
    catalans = [catalan_number(n) for n in ns]
    ratios = [(4 * n + 2) / (n + 2) for n in range(1, max_n + 1)]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle("Catalan Numbers: Growth and Ratio Convergence",
                 fontsize=14, fontweight='bold')

    # Left: Catalan number growth (log scale)
    ax1.semilogy(ns, catalans, 'bo-', markersize=4, linewidth=1.5, label=r'$C_n$')
    ax1.semilogy(ns, [4**n / (np.sqrt(np.pi) * n**1.5) if n > 0 else 1 for n in ns],
                 'r--', linewidth=1.5, alpha=0.7,
                 label=r'$4^n / (\sqrt{\pi} n^{3/2})$')
    ax1.set_xlabel('n', fontsize=12)
    ax1.set_ylabel(r'$C_n$', fontsize=12)
    ax1.set_title('Catalan Number Growth')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right: Ratio convergence
    ax2.plot(range(1, max_n + 1), ratios, 'go-', markersize=4, linewidth=1.5,
             label=r'$C_{n+1}/C_n = (4n+2)/(n+2)$')
    ax2.axhline(y=4, color='red', linestyle='--', linewidth=1.5, alpha=0.7,
                label='Limit = 4')
    ax2.set_xlabel('n', fontsize=12)
    ax2.set_ylabel(r'$C_{n+1}/C_n$', fontsize=12)
    ax2.set_title('Ratio Convergence to 4')
    ax2.legend(fontsize=10)
    ax2.set_ylim(1, 4.5)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_catalan.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_catalan.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Wigner Semicircle Law Convergence

Shows how the empirical spectral density of random Wigner matrices
converges to the semicircle distribution as n grows.
"""

import numpy as np
import matplotlib.pyplot as plt


def wigner_density(x):
    """Semicircle density ρ(x) = (2/π)√(1-x²) for |x| ≤ 1."""
    mask = np.abs(x) <= 1
    result = np.zeros_like(x)
    result[mask] = (2 / np.pi) * np.sqrt(1 - x[mask]**2)
    return result


def generate_wigner_matrix(n, dist="gaussian"):
    """Generate an n×n symmetric random matrix."""
    if dist == "gaussian":
        A = np.random.randn(n, n) / np.sqrt(n)
    elif dist == "bernoulli":
        A = np.random.choice([-1, 1], size=(n, n)) / np.sqrt(n)
    else:
        A = (np.random.rand(n, n) - 0.5) * np.sqrt(12) / np.sqrt(n)
    return (A + A.T) / np.sqrt(2)


def main():
    np.random.seed(42)

    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    fig.suptitle("Wigner Semicircle Law: Convergence of Spectral Density",
                 fontsize=14, fontweight='bold')

    sizes = [20, 100, 500, 2000]
    num_trials = 50
    x_theory = np.linspace(-2.5, 2.5, 500)

    for ax, n in zip(axes.flat, sizes):
        all_eigs = []
        for _ in range(num_trials):
            W = generate_wigner_matrix(n)
            eigs = np.linalg.eigvalsh(W)
            all_eigs.extend(eigs.tolist())

        all_eigs = np.array(all_eigs)

        ax.hist(all_eigs, bins=80, density=True, alpha=0.6,
                color='steelblue', edgecolor='white', linewidth=0.5,
                label=f'Empirical (n={n})')
        ax.plot(x_theory, wigner_density(x_theory), 'r-', linewidth=2,
                label='Semicircle ρ(x)')
        ax.set_xlim(-2.5, 2.5)
        ax.set_ylim(0, 0.8)
        ax.set_xlabel('x')
        ax.set_ylabel('Density')
        ax.set_title(f'n = {n}, {num_trials} trials')
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_semicircle.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_semicircle.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Tracy-Widom Edge Statistics and Universality

Shows the distribution of the scaled largest eigenvalue for different
entry distributions, demonstrating edge universality.
"""

import numpy as np
import matplotlib.pyplot as plt


def generate_wigner_matrix(n, dist="gaussian"):
    """Generate an n×n symmetric random matrix."""
    if dist == "gaussian":
        A = np.random.randn(n, n) / np.sqrt(n)
    elif dist == "bernoulli":
        A = np.random.choice([-1, 1], size=(n, n)) / np.sqrt(n)
    else:
        A = (np.random.rand(n, n) - 0.5) * np.sqrt(12) / np.sqrt(n)
    return (A + A.T) / np.sqrt(2)


def largest_eigenvalue_scaled(W):
    """Compute n^{2/3}(λ_max/√n - 2)."""
    n = W.shape[0]
    eigs = np.linalg.eigvalsh(W)
    lmax = eigs[-1]
    return n**(2/3) * (lmax * np.sqrt(n) - 2)


def main():
    np.random.seed(123)

    n = 300
    num_trials = 2000
    distributions = {
        "Gaussian": "gaussian",
        "Bernoulli (±1)": "bernoulli",
        "Uniform": "uniform",
    }

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle(f"Edge Universality: Scaled Largest Eigenvalue (n={n})",
                 fontsize=14, fontweight='bold')

    colors = ['steelblue', 'coral', 'seagreen']
    all_data = {}

    for (label, dist), ax, color in zip(distributions.items(), axes, colors):
        scaled_max = []
        for _ in range(num_trials):
            W = generate_wigner_matrix(n, dist)
            s = largest_eigenvalue_scaled(W)
            scaled_max.append(s)

        scaled_max = np.array(scaled_max)
        all_data[label] = scaled_max

        ax.hist(scaled_max, bins=60, density=True, alpha=0.7,
                color=color, edgecolor='white', linewidth=0.5)
        ax.set_xlabel(r"$n^{2/3}(\lambda_{\max}/\sqrt{n} - 2)$")
        ax.set_ylabel("Density")
        ax.set_title(f"{label}\nmean={np.mean(scaled_max):.2f}, std={np.std(scaled_max):.2f}")
        ax.axvline(np.mean(scaled_max), color='black', linestyle='--', alpha=0.5)
        ax.set_xlim(-8, 4)
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_tracy_widom.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_tracy_widom.png")

    # Overlay plot
    fig2, ax2 = plt.subplots(figsize=(10, 6))
    for (label, data), color in zip(all_data.items(), colors):
        ax2.hist(data, bins=60, density=True, alpha=0.4,
                 color=color, edgecolor=color, linewidth=0.5, label=label)

    ax2.set_xlabel(r"$n^{2/3}(\lambda_{\max}/\sqrt{n} - 2)$", fontsize=12)
    ax2.set_ylabel("Density", fontsize=12)
    ax2.set_title(f"Edge Universality: All Distributions Overlap (n={n})",
                  fontsize=14, fontweight='bold')
    ax2.legend(fontsize=11)
    ax2.set_xlim(-8, 4)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_tracy_widom_overlay.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_tracy_widom_overlay.png")


if __name__ == "__main__":
    main()
