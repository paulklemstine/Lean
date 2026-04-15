"""
Sheffer Algebra v5 Demonstrations
=================================

New computational experiments supporting the formally verified theorems in v5.
Includes:
  1. C∞ verification: higher derivatives of softplus
  2. Iterated softplus growth rate analysis (Q24)
  3. Ring completion visualization
  4. Third barrier candidates: oscillation analysis
  5. Sheffer expression landscape
  6. sin(x) vs Sheffer approximation (Q21 investigation)
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from scipy import optimize
from typing import Callable, List, Tuple

# ============================================================
# Core Functions
# ============================================================

def softplus(x: np.ndarray) -> np.ndarray:
    """σ(x) = log(1 + exp(x)), numerically stable"""
    return np.where(x > 20, x, np.log1p(np.exp(np.clip(x, -500, 20))))

def sigmoid(x: np.ndarray) -> np.ndarray:
    """S(x) = exp(x)/(1+exp(x)), numerically stable"""
    return np.where(x > 0,
                    1 / (1 + np.exp(-x)),
                    np.exp(x) / (1 + np.exp(x)))

def softplus_inv(y: np.ndarray) -> np.ndarray:
    """σ⁻¹(y) = log(exp(y) - 1) for y > 0"""
    return np.where(y > 20, y, np.log(np.expm1(np.clip(y, 1e-10, 20))))

def logit(p: np.ndarray) -> np.ndarray:
    """logit(p) = log(p/(1-p)) for p ∈ (0,1)"""
    return np.log(p / (1 - p))

# ============================================================
# Demo 1: Higher Derivatives of Softplus (Q23 - C∞ Barrier)
# ============================================================

def demo_higher_derivatives():
    """Compute and plot derivatives of softplus up to order 6."""
    x = np.linspace(-5, 5, 1000)

    # σ'(x) = S(x)
    d1 = sigmoid(x)
    # σ''(x) = S(x)(1-S(x))
    d2 = d1 * (1 - d1)
    # σ'''(x) = S(x)(1-S(x))(1-2S(x))
    d3 = d2 * (1 - 2*d1)
    # σ⁽⁴⁾(x) = S(x)(1-S(x))(1 - 6S(x)(1-S(x)))
    d4 = d2 * (1 - 6*d1*(1-d1))
    # σ⁽⁵⁾(x) via chain
    d5 = d2 * (1 - 2*d1) * (1 - 12*d1*(1-d1)) + d2 * (-2*d2) * (1 - 6*d1*(1-d1))

    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle('C∞ Barrier: All Derivatives of Softplus Exist and Are Smooth',
                 fontsize=14, fontweight='bold')

    data = [
        (softplus(x), "σ(x) = log(1+eˣ)", 'blue'),
        (d1, "σ'(x) = sigmoid(x)", 'green'),
        (d2, "σ''(x) = S(x)(1-S(x))", 'red'),
        (d3, "σ'''(x)", 'purple'),
        (d4, "σ⁽⁴⁾(x)", 'orange'),
        (d5, "σ⁽⁵⁾(x)", 'brown'),
    ]

    for ax, (y, title, color) in zip(axes.flat, data):
        ax.plot(x, y, color=color, linewidth=2)
        ax.set_title(title, fontsize=11)
        ax.grid(True, alpha=0.3)
        ax.axhline(y=0, color='gray', linewidth=0.5)
        ax.axvline(x=0, color='gray', linewidth=0.5)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/New/ShefferAI/Python/plots/higher_derivatives.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 1: Higher derivatives plotted")

# ============================================================
# Demo 2: Iterated Softplus Growth Rate (Q24)
# ============================================================

def demo_iterated_softplus_growth():
    """Analyze the growth rate of σⁿ(0) to resolve Q24."""
    max_n = 200
    values = np.zeros(max_n + 1)
    values[0] = 0.0

    for n in range(1, max_n + 1):
        values[n] = softplus(values[n-1])

    ns = np.arange(1, max_n + 1)
    vals = values[1:]

    # Test various growth models
    log_n = np.log(ns)
    log2 = np.log(2)

    # Fit σⁿ(0) ≈ a * log(n) + b
    # Use least squares
    A = np.column_stack([log_n, np.ones_like(log_n)])
    coeffs, _, _, _ = np.linalg.lstsq(A, vals, rcond=None)
    a_fit, b_fit = coeffs

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Iterated Softplus Growth Rate (Q24)', fontsize=14, fontweight='bold')

    # Plot 1: Raw values
    axes[0,0].plot(ns, vals, 'b-', linewidth=2, label='σⁿ(0)')
    axes[0,0].plot(ns, (ns+1) * log2, 'r--', linewidth=1, label='(n+1)·log 2 (upper bound)')
    axes[0,0].plot(ns, a_fit * log_n + b_fit, 'g--', linewidth=1,
                   label=f'{a_fit:.3f}·log(n) + {b_fit:.3f}')
    axes[0,0].set_xlabel('n')
    axes[0,0].set_ylabel('σⁿ(0)')
    axes[0,0].legend()
    axes[0,0].set_title('Iterated softplus values')
    axes[0,0].grid(True, alpha=0.3)

    # Plot 2: Ratio σⁿ(0) / log(n)
    ratios = vals / np.where(log_n > 0, log_n, 1)
    axes[0,1].plot(ns[5:], ratios[5:], 'b-', linewidth=2)
    axes[0,1].axhline(y=a_fit, color='r', linestyle='--', label=f'Limit ≈ {a_fit:.4f}')
    axes[0,1].set_xlabel('n')
    axes[0,1].set_ylabel('σⁿ(0) / log(n)')
    axes[0,1].set_title('Ratio test: convergence to constant')
    axes[0,1].legend()
    axes[0,1].grid(True, alpha=0.3)

    # Plot 3: Differences σⁿ⁺¹(0) - σⁿ(0)
    diffs = np.diff(values[1:])
    axes[1,0].plot(ns[:-1], diffs, 'b-', linewidth=2, label='σⁿ⁺¹(0) - σⁿ(0)')
    axes[1,0].plot(ns[:-1], a_fit / ns[:-1], 'r--', linewidth=1, label=f'≈ {a_fit:.3f}/n')
    axes[1,0].set_xlabel('n')
    axes[1,0].set_ylabel('Increment')
    axes[1,0].set_title('Increments decay like O(1/n)')
    axes[1,0].legend()
    axes[1,0].grid(True, alpha=0.3)

    # Plot 4: σⁿ(0) vs various models
    axes[1,1].plot(ns, vals, 'b-', linewidth=2, label='σⁿ(0)')
    axes[1,1].plot(ns, a_fit * log_n + b_fit, 'g--', linewidth=1,
                   label=f'Best fit: {a_fit:.3f}·log(n) + {b_fit:.3f}')
    axes[1,1].plot(ns, np.log(ns) + np.log(log2), 'r:', linewidth=1,
                   label='log(n) + log(log 2)')
    axes[1,1].set_xlabel('n')
    axes[1,1].set_ylabel('σⁿ(0)')
    axes[1,1].set_title(f'Growth rate: σⁿ(0) ~ {a_fit:.3f}·log(n)')
    axes[1,1].legend()
    axes[1,1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/New/ShefferAI/Python/plots/iterated_growth.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print(f"✓ Demo 2: Iterated softplus growth ≈ {a_fit:.4f}·log(n) + {b_fit:.4f}")
    print(f"  First 10 values: {[f'{v:.4f}' for v in values[1:11]]}")
    print(f"  σ¹⁰⁰(0) = {values[100]:.6f}, 101·log(2) = {101*log2:.6f}")

# ============================================================
# Demo 3: Ring Completion Analysis (Q22)
# ============================================================

def demo_ring_completion():
    """Visualize what happens when we close ShefferAlg under multiplication."""
    x = np.linspace(-5, 5, 1000)

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Ring Completion: Closing ShefferAlg Under ×', fontsize=14, fontweight='bold')

    # Plot 1: Products of Sheffer functions
    s = softplus(x)
    axes[0,0].plot(x, s, 'b-', label='σ(x)')
    axes[0,0].plot(x, s**2, 'r-', label='σ(x)²')
    axes[0,0].plot(x, s * softplus(-x), 'g-', label='σ(x)·σ(-x)')
    axes[0,0].set_title('Products of Sheffer functions')
    axes[0,0].legend()
    axes[0,0].grid(True, alpha=0.3)

    # Plot 2: x² is NOT Lipschitz
    axes[0,1].plot(x, x**2, 'r-', linewidth=2, label='x² (not Lipschitz)')
    axes[0,1].plot(x, np.abs(x), 'b--', label='|x| (Lipschitz, not smooth)')
    axes[0,1].plot(x, softplus(x), 'g-', label='σ(x) (Lipschitz & smooth)')
    axes[0,1].set_title('Why x² breaks the Lipschitz barrier')
    axes[0,1].legend()
    axes[0,1].grid(True, alpha=0.3)

    # Plot 3: Derivative growth shows non-Lipschitz
    axes[1,0].plot(x, 2*np.abs(x), 'r-', linewidth=2, label="|d/dx(x²)| = 2|x|")
    axes[1,0].plot(x, sigmoid(x), 'g-', label="σ'(x) = S(x) ≤ 1")
    axes[1,0].axhline(y=1, color='gray', linestyle=':', label="Lipschitz bound = 1")
    axes[1,0].set_title('Derivative magnitudes')
    axes[1,0].legend()
    axes[1,0].grid(True, alpha=0.3)

    # Plot 4: Hierarchy of closures
    axes[1,1].text(0.5, 0.85, 'All Functions ℝ → ℝ', ha='center', fontsize=14,
                   transform=axes[1,1].transAxes)
    axes[1,1].text(0.5, 0.7, '⊃ Ring Completion of ShefferAlg', ha='center', fontsize=12,
                   transform=axes[1,1].transAxes, color='red')
    axes[1,1].text(0.5, 0.55, '⊃ C∞(ℝ) (smooth functions)', ha='center', fontsize=12,
                   transform=axes[1,1].transAxes)
    axes[1,1].text(0.5, 0.4, '⊃ C∞(ℝ) ∩ Lip(ℝ)', ha='center', fontsize=12,
                   transform=axes[1,1].transAxes, color='blue')
    axes[1,1].text(0.5, 0.25, '⊃ ShefferAlgebra', ha='center', fontsize=14,
                   transform=axes[1,1].transAxes, color='green', fontweight='bold')
    axes[1,1].text(0.5, 0.1, '(vector space + composition monoid)', ha='center',
                   fontsize=10, transform=axes[1,1].transAxes, style='italic')
    axes[1,1].axis('off')
    axes[1,1].set_title('Containment hierarchy')

    plt.tight_layout()
    plt.savefig('/workspace/request-project/New/ShefferAI/Python/plots/ring_completion.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 3: Ring completion analysis plotted")

# ============================================================
# Demo 4: sin(x) Investigation (Q21)
# ============================================================

def demo_sin_investigation():
    """Can sin(x) be approximated by Sheffer expressions?
    sin is C∞ ∩ Lip, so it passes both barriers.
    Key question: is there a THIRD barrier excluding it?"""
    x = np.linspace(-6, 6, 1000)

    # Attempt to fit sin(x) using Sheffer expressions
    # σ(ax+b) - σ(cx+d) can approximate bumps

    def sheffer_fit(params, x):
        """Sum of affine-transformed softplus functions"""
        n = len(params) // 3
        result = np.zeros_like(x)
        for i in range(n):
            w, a, b = params[3*i], params[3*i+1], params[3*i+2]
            result += w * softplus(a * x + b)
        return result

    def loss(params, x, y_target):
        return np.sum((sheffer_fit(params, x) - y_target)**2)

    y_target = np.sin(x)

    # Try fitting with increasing numbers of terms
    results = []
    for n_terms in [2, 4, 8, 16, 32]:
        best_loss = float('inf')
        for trial in range(5):
            p0 = np.random.randn(3 * n_terms) * 0.5
            try:
                res = optimize.minimize(loss, p0, args=(x, y_target),
                                        method='L-BFGS-B', options={'maxiter': 2000})
                if res.fun < best_loss:
                    best_loss = res.fun
                    best_params = res.x
            except:
                pass
        results.append((n_terms, best_loss, best_params))

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Q21: Can sin(x) Be in the Sheffer Algebra?', fontsize=14, fontweight='bold')

    # Plot 1: Best Sheffer approximation to sin
    axes[0,0].plot(x, y_target, 'b-', linewidth=2, label='sin(x)')
    for n_terms, loss_val, params in results[-2:]:
        y_fit = sheffer_fit(params, x)
        axes[0,0].plot(x, y_fit, '--', label=f'{n_terms} terms (L²={loss_val:.2f})')
    axes[0,0].set_title('Sheffer approximation of sin(x)')
    axes[0,0].legend()
    axes[0,0].grid(True, alpha=0.3)

    # Plot 2: Approximation error vs number of terms
    ns = [r[0] for r in results]
    losses = [r[1] for r in results]
    axes[0,1].semilogy(ns, losses, 'ro-', linewidth=2, markersize=8)
    axes[0,1].set_xlabel('Number of softplus terms')
    axes[0,1].set_ylabel('L² error')
    axes[0,1].set_title('Approximation error (log scale)')
    axes[0,1].grid(True, alpha=0.3)

    # Plot 3: Key difference - oscillation
    axes[1,0].plot(x, np.sin(x), 'b-', linewidth=2, label='sin(x) oscillates')
    axes[1,0].plot(x, softplus(x) - softplus(-x), 'r-', linewidth=2,
                   label='σ(x)-σ(-x)=x (monotone)')
    axes[1,0].plot(x, softplus(x) - softplus(x-3), 'g-', linewidth=2,
                   label='σ(x)-σ(x-3) (monotone-like)')
    axes[1,0].set_title('Oscillation: potential third barrier')
    axes[1,0].legend()
    axes[1,0].grid(True, alpha=0.3)

    # Plot 4: Asymptotic behavior
    x_wide = np.linspace(-20, 20, 2000)
    axes[1,1].plot(x_wide, np.sin(x_wide), 'b-', alpha=0.7, label='sin(x): bounded, oscillating')
    axes[1,1].plot(x_wide, softplus(x_wide), 'r-', label='σ(x): monotone, unbounded')
    axes[1,1].plot(x_wide, sigmoid(x_wide), 'g-', label='S(x): monotone, bounded')
    axes[1,1].set_title('Asymptotic behavior comparison')
    axes[1,1].legend()
    axes[1,1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/New/ShefferAI/Python/plots/sin_investigation.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 4: sin(x) investigation plotted")

# ============================================================
# Demo 5: Softplus Inverse and Bijection Properties
# ============================================================

def demo_bijections():
    """Demonstrate softplus and sigmoid as bijections with their inverses."""
    x = np.linspace(-5, 5, 1000)
    y_sp = np.linspace(0.01, 8, 1000)
    y_sig = np.linspace(0.01, 0.99, 1000)

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Softplus and Sigmoid Bijections (Formally Verified)', fontsize=14, fontweight='bold')

    # Plot 1: Softplus and its inverse
    axes[0,0].plot(x, softplus(x), 'b-', linewidth=2, label='σ(x): ℝ → (0,∞)')
    axes[0,0].plot(y_sp, softplus_inv(y_sp), 'r--', linewidth=2, label='σ⁻¹(y): (0,∞) → ℝ')
    axes[0,0].plot(x, x, 'gray', linewidth=0.5, linestyle=':')
    axes[0,0].set_title('Softplus bijection: ℝ ↔ (0,∞)')
    axes[0,0].legend()
    axes[0,0].grid(True, alpha=0.3)
    axes[0,0].set_xlim(-5, 5)
    axes[0,0].set_ylim(-5, 8)

    # Plot 2: Sigmoid and logit
    axes[0,1].plot(x, sigmoid(x), 'b-', linewidth=2, label='S(x): ℝ → (0,1)')
    axes[0,1].plot(y_sig, logit(y_sig), 'r--', linewidth=2, label='logit(y): (0,1) → ℝ')
    axes[0,1].set_title('Sigmoid bijection: ℝ ↔ (0,1)')
    axes[0,1].legend()
    axes[0,1].grid(True, alpha=0.3)

    # Plot 3: Verify round-trip σ(σ⁻¹(y)) = y
    errors_sp = np.abs(softplus(softplus_inv(y_sp)) - y_sp)
    axes[1,0].semilogy(y_sp, errors_sp + 1e-16, 'b-', linewidth=2)
    axes[1,0].set_xlabel('y')
    axes[1,0].set_ylabel('|σ(σ⁻¹(y)) - y|')
    axes[1,0].set_title('Round-trip error: σ ∘ σ⁻¹ = id')
    axes[1,0].grid(True, alpha=0.3)

    # Plot 4: Verify round-trip S(logit(p)) = p
    errors_sig = np.abs(sigmoid(logit(y_sig)) - y_sig)
    axes[1,1].semilogy(y_sig, errors_sig + 1e-16, 'r-', linewidth=2)
    axes[1,1].set_xlabel('p')
    axes[1,1].set_ylabel('|S(logit(p)) - p|')
    axes[1,1].set_title('Round-trip error: S ∘ logit = id')
    axes[1,1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/New/ShefferAI/Python/plots/bijections.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 5: Bijection properties plotted")

# ============================================================
# Demo 6: Two-Barrier + Third Barrier Classification
# ============================================================

def demo_three_barrier_classification():
    """Extended classification including potential third barrier."""
    functions = {
        'In ShefferAlg': {
            'σ(x)': (softplus, True, True, True),
            'x': (lambda x: x, True, True, True),
            '2σ(x)-x': (lambda x: 2*softplus(x)-x, True, True, True),
        },
        'Lipschitz ✗': {
            'eˣ': (np.exp, True, False, None),
            'x²': (lambda x: x**2, True, False, None),
            'sinh(x)': (np.sinh, True, False, None),
        },
        'Smooth ✗': {
            '|x|': (np.abs, False, True, None),
            'ReLU': (lambda x: np.maximum(0, x), False, True, None),
        },
        'Both ✓, Q21 open': {
            'sin(x)': (np.sin, True, True, '?'),
            'tanh(x)': (np.tanh, True, True, '?'),
            'arctan(x)': (np.arctan, True, True, '?'),
        },
    }

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Three-Barrier Classification System', fontsize=14, fontweight='bold')

    x = np.linspace(-5, 5, 500)
    colors = ['blue', 'green', 'purple', 'cyan', 'orange']

    for ax, (category, funcs) in zip(axes.flat, functions.items()):
        for (name, (f, _, _, _)), c in zip(funcs.items(), colors):
            ax.plot(x, f(x), color=c, linewidth=2, label=name)
        ax.set_title(category, fontsize=12, fontweight='bold')
        ax.legend()
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/New/ShefferAI/Python/plots/three_barriers.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 6: Three-barrier classification plotted")

# ============================================================
# Demo 7: Sheffer Algebra Dimension Analysis
# ============================================================

def demo_dimension_analysis():
    """Show the Sheffer algebra is infinite-dimensional by
    demonstrating σ(x+n) for different n are linearly independent."""
    x = np.linspace(-5, 5, 1000)

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    fig.suptitle('Sheffer Algebra: Infinite-Dimensional Vector Space', fontsize=14, fontweight='bold')

    # Plot 1: Family of translated softplus
    for n in range(8):
        axes[0].plot(x, softplus(x + n), label=f'σ(x+{n})')
    axes[0].set_title('Translated softplus family {σ(x+n)}')
    axes[0].legend(fontsize=8, ncol=2)
    axes[0].grid(True, alpha=0.3)

    # Plot 2: Gram matrix (shows linear independence)
    n_funcs = 10
    N = 200
    x_sample = np.linspace(-5, 5, N)
    V = np.zeros((n_funcs, N))
    for i in range(n_funcs):
        V[i] = softplus(x_sample + i)
    G = V @ V.T / N  # Gram matrix
    eigenvalues = np.linalg.eigvalsh(G)

    axes[1].bar(range(n_funcs), eigenvalues[::-1])
    axes[1].set_xlabel('Eigenvalue index')
    axes[1].set_ylabel('Eigenvalue')
    axes[1].set_title(f'Gram matrix eigenvalues (all > 0 ⟹ lin. independent)')
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/New/ShefferAI/Python/plots/dimension_analysis.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 7: Dimension analysis plotted")

# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    import os
    os.makedirs('/workspace/request-project/New/ShefferAI/Python/plots', exist_ok=True)

    print("=" * 60)
    print("Sheffer Algebra v5 Demonstrations")
    print("=" * 60)

    demo_higher_derivatives()
    demo_iterated_softplus_growth()
    demo_ring_completion()
    demo_sin_investigation()
    demo_bijections()
    demo_three_barrier_classification()
    demo_dimension_analysis()

    print("\n" + "=" * 60)
    print("All demos complete!")
    print("=" * 60)
