"""
Vector-Valued EML Stone–Weierstrass: Demonstrations and Visualizations

This script demonstrates the key theorems proved in the formal Lean development:
1. Coordinatewise density: scalar approximation lifts to vector-valued outputs
2. Coupled class density: shared features + continuous readout suffice
3. Softmax projection: simplex-valued outputs via softmax
4. Retraction-based constrained approximation

Each demo uses concrete numerical examples with EML-like basis functions
(exponentials and sigmoids) to illustrate the theorems.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import os

os.makedirs("demos/figures", exist_ok=True)


# ─── EML Basis Functions ────────────────────────────────────────────────────

def sigmoid(x):
    return 1.0 / (1.0 + np.exp(-np.clip(x, -500, 500)))

def eml_logistic_gen(x, w, b):
    return sigmoid(w * x + b)

def softmax(z):
    z_shifted = z - np.max(z, axis=-1, keepdims=True)
    e = np.exp(z_shifted)
    return e / np.sum(e, axis=-1, keepdims=True)


# ─── Demo 1: Coordinatewise Vector Approximation ────────────────────────────

def demo_coordinatewise_approximation():
    print("=" * 70)
    print("Demo 1: Coordinatewise Vector Approximation")
    print("  (Theorem: closure_vecClass_eq_univ_of_scalar)")
    print("=" * 70)

    x = np.linspace(0, 2 * np.pi, 500)
    F = np.column_stack([np.sin(x), np.cos(x), np.sin(2 * x)])

    fig, axes = plt.subplots(3, 1, figsize=(12, 10), sharex=True)
    coord_names = [r'$\sin(x)$', r'$\cos(x)$', r'$\sin(2x)$']
    errors_by_terms = {5: [], 10: [], 20: []}

    for coord_idx in range(3):
        target = F[:, coord_idx]
        for n_t, color in [(5, 'lightblue'), (10, 'orange'), (20, 'green')]:
            approx = np.zeros_like(x)
            np.random.seed(42 + coord_idx * 100)
            for k in range(n_t):
                w_k = np.random.randn() * 2
                b_k = np.random.randn() * 3
                basis = eml_logistic_gen(x, w_k, b_k)
                if np.std(basis) > 1e-10:
                    coeff = np.dot(target - approx, basis) / np.dot(basis, basis)
                    approx += coeff * basis
            err = np.max(np.abs(target - approx))
            errors_by_terms[n_t].append(err)
            if n_t == 20:
                axes[coord_idx].plot(x, approx, '--', color='red', alpha=0.8,
                                    label=f'EML approx ({n_t} terms), err={err:.4f}')
        axes[coord_idx].plot(x, target, 'b-', linewidth=2,
                             label=f'Target: {coord_names[coord_idx]}')
        axes[coord_idx].set_ylabel(f'Coordinate {coord_idx + 1}')
        axes[coord_idx].legend(loc='upper right')
        axes[coord_idx].grid(True, alpha=0.3)

    axes[-1].set_xlabel('x')
    fig.suptitle(r'Coordinatewise Vector Approximation: '
                 r'$F(x) = (\sin x, \cos x, \sin 2x) \in C([0,2\pi], \mathbb{R}^3)$',
                 fontsize=13)
    plt.tight_layout()
    plt.savefig('demos/figures/demo1_coordinatewise.png', dpi=150, bbox_inches='tight')
    plt.close()

    print("\nVector approximation errors (sup norm):")
    for n_t in [5, 10, 20]:
        vec_err = max(errors_by_terms[n_t])
        print(f"  {n_t} terms: max coord error = {vec_err:.6f}")
    print("  Vector error = max of coordinate errors (sup norm on Fin m -> R).\n")


# ─── Demo 2: Coupled Class vs Coordinatewise ────────────────────────────────

def demo_coupled_class():
    print("=" * 70)
    print("Demo 2: Coupled Class — Shared Features + Continuous Readout")
    print("  (Theorem: dense_coupledVecClass_of_dense_scalar)")
    print("=" * 70)

    x = np.linspace(-3, 3, 500)
    F = np.column_stack([x**2, x**3])

    k = 8
    np.random.seed(123)
    features = np.zeros((len(x), k))
    for j in range(k):
        w_j = np.random.randn() * 1.5
        b_j = np.random.randn() * 2
        features[:, j] = eml_logistic_gen(x, w_j, b_j)

    W, _, _, _ = np.linalg.lstsq(features, F, rcond=None)
    G_coupled = features @ W

    G_coord = np.zeros_like(F)
    for coord_idx in range(2):
        np.random.seed(200 + coord_idx)
        features_c = np.zeros((len(x), k))
        for j in range(k):
            w_j = np.random.randn() * 1.5
            b_j = np.random.randn() * 2
            features_c[:, j] = eml_logistic_gen(x, w_j, b_j)
        W_c, _, _, _ = np.linalg.lstsq(features_c, F[:, coord_idx:coord_idx+1], rcond=None)
        G_coord[:, coord_idx] = (features_c @ W_c).flatten()

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    theta = np.linspace(0, 2*np.pi, 100)
    axes[0].plot(F[:, 0], F[:, 1], 'b-', linewidth=2, label='Target')
    axes[0].plot(G_coupled[:, 0], G_coupled[:, 1], 'r--', linewidth=1.5, label='Coupled')
    axes[0].plot(G_coord[:, 0], G_coord[:, 1], 'g:', linewidth=1.5, label='Coordinatewise')
    axes[0].set_xlabel(r'$x^2$'); axes[0].set_ylabel(r'$x^3$')
    axes[0].set_title('Output space')
    axes[0].legend(); axes[0].grid(True, alpha=0.3)

    err_c = np.max(np.abs(F - G_coupled), axis=1)
    err_i = np.max(np.abs(F - G_coord), axis=1)
    axes[1].plot(x, err_c, 'r-', label=f'Coupled (max={np.max(err_c):.4f})')
    axes[1].plot(x, err_i, 'g-', label=f'Coordinatewise (max={np.max(err_i):.4f})')
    axes[1].set_xlabel('x'); axes[1].set_ylabel('Error')
    axes[1].set_title('Error comparison')
    axes[1].legend(); axes[1].grid(True, alpha=0.3)

    fig.suptitle(r'Coupled vs Coordinatewise: $F(x) = (x^2, x^3)$', fontsize=14)
    plt.tight_layout()
    plt.savefig('demos/figures/demo2_coupled_class.png', dpi=150, bbox_inches='tight')
    plt.close()

    print(f"\n  Coupled error:       {np.max(err_c):.6f}")
    print(f"  Coordinatewise error: {np.max(err_i):.6f}")
    print("  VecClass ⊆ CoupledVecClass (shared features match real architectures).\n")


# ─── Demo 3: Softmax and Simplex-Valued Outputs ─────────────────────────────

def demo_softmax_simplex():
    print("=" * 70)
    print("Demo 3: Softmax Projection onto the Probability Simplex")
    print("  (Theorems: softmaxMap_mem_stdSimplex, approx_simplex_interior)")
    print("=" * 70)

    x = np.linspace(0, 2 * np.pi, 500)
    m = 3
    raw = np.column_stack([2 + np.sin(x), 2 + np.cos(x), 2 + np.sin(x + np.pi/3)])
    F_target = raw / raw.sum(axis=1, keepdims=True)
    logits = np.log(F_target)

    F_reconstructed = softmax(logits)
    reconstruction_error = np.max(np.abs(F_target - F_reconstructed))

    n_basis = 15
    np.random.seed(456)
    approx_logits = np.zeros_like(logits)
    for i in range(m):
        for k in range(n_basis):
            w_k = np.random.randn() * 1.5
            b_k = np.random.randn() * 2
            basis = eml_logistic_gen(x, w_k, b_k)
            if np.std(basis) > 1e-10:
                coeff = np.dot(logits[:, i] - approx_logits[:, i], basis) / np.dot(basis, basis)
                approx_logits[:, i] += coeff * basis

    G_softmax = softmax(approx_logits)

    fig = plt.figure(figsize=(15, 10))
    gs = GridSpec(2, 2, figure=fig)

    colors = ['b', 'r', 'g']
    ax1 = fig.add_subplot(gs[0, 0])
    for i in range(m):
        ax1.plot(x, F_target[:, i], colors[i], linewidth=2, label=f'Class {i+1}')
    ax1.set_ylabel('Probability'); ax1.set_title('Target F(x) ∈ Δ²')
    ax1.legend(); ax1.grid(True, alpha=0.3); ax1.set_ylim(0, 0.6)

    ax2 = fig.add_subplot(gs[0, 1])
    for i in range(m):
        ax2.plot(x, G_softmax[:, i], colors[i], linewidth=2, label=f'Class {i+1}')
    ax2.set_ylabel('Probability'); ax2.set_title('Softmax ∘ EML logits')
    ax2.legend(); ax2.grid(True, alpha=0.3); ax2.set_ylim(0, 0.6)

    ax3 = fig.add_subplot(gs[1, 0])
    corners = np.array([[0, 0], [1, 0], [0.5, np.sqrt(3)/2]])
    target_2d = F_target @ corners
    approx_2d = G_softmax @ corners
    ax3.plot(target_2d[:, 0], target_2d[:, 1], 'b-', linewidth=2, label='Target')
    ax3.plot(approx_2d[:, 0], approx_2d[:, 1], 'r--', linewidth=1.5, label='Approx')
    tri = plt.Polygon(corners, fill=False, edgecolor='gray', linewidth=1)
    ax3.add_patch(tri)
    ax3.set_xlim(-0.1, 1.1); ax3.set_ylim(-0.1, 1.0)
    ax3.set_aspect('equal'); ax3.set_title('Simplex Δ² trajectory'); ax3.legend()

    ax4 = fig.add_subplot(gs[1, 1])
    pe = np.max(np.abs(F_target - G_softmax), axis=1)
    ax4.plot(x, pe, 'k-', linewidth=1.5)
    ax4.set_xlabel('x'); ax4.set_ylabel('Error')
    ax4.set_title(f'Error (max = {np.max(pe):.6f})'); ax4.grid(True, alpha=0.3)

    fig.suptitle('Simplex-Valued Approximation via Softmax', fontsize=14)
    plt.tight_layout()
    plt.savefig('demos/figures/demo3_simplex_softmax.png', dpi=150, bbox_inches='tight')
    plt.close()

    print(f"\n  softmax(log(F)) = F check: {reconstruction_error:.2e}")
    print(f"  Approximation error: {np.max(pe):.6f}")
    print("  Softmax maps logits into Δ (softmaxMap_mem_stdSimplex).")
    print("  Logit ↔ simplex interior bijection enables approx_simplex_interior.\n")


# ─── Demo 4: Retraction-Based Constrained Approximation ─────────────────────

def demo_retraction():
    print("=" * 70)
    print("Demo 4: Retraction-Based Constrained Approximation")
    print("  (Theorem: dense_into_compactRange_of_retraction)")
    print("=" * 70)

    x = np.linspace(0, 2 * np.pi, 500)
    F = np.column_stack([0.5 * np.cos(x), 0.5 * np.sin(x)])

    def disk_retraction(y):
        norms = np.linalg.norm(y, axis=1, keepdims=True)
        return y / np.maximum(1.0, norms)

    n_basis = 12
    np.random.seed(789)
    G_ambient = np.zeros_like(F)
    for coord in range(2):
        for k in range(n_basis):
            w_k = np.random.randn() * 2
            b_k = np.random.randn() * 3
            basis = eml_logistic_gen(x, w_k, b_k)
            if np.std(basis) > 1e-10:
                coeff = np.dot(F[:, coord] - G_ambient[:, coord], basis) / np.dot(basis, basis)
                G_ambient[:, coord] += coeff * basis

    G_retracted = disk_retraction(G_ambient)

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    theta_c = np.linspace(0, 2*np.pi, 100)

    axes[0].plot(np.cos(theta_c), np.sin(theta_c), 'gray', linewidth=1, linestyle='--')
    axes[0].plot(F[:, 0], F[:, 1], 'b-', linewidth=2, label='Target F')
    axes[0].plot(G_ambient[:, 0], G_ambient[:, 1], 'r--', linewidth=1.5, label='Ambient G')
    axes[0].set_aspect('equal'); axes[0].set_title('Step 1: Ambient approx')
    axes[0].legend(); axes[0].grid(True, alpha=0.3)

    axes[1].plot(np.cos(theta_c), np.sin(theta_c), 'gray', linewidth=1, linestyle='--')
    axes[1].plot(F[:, 0], F[:, 1], 'b-', linewidth=2, label='Target F')
    axes[1].plot(G_retracted[:, 0], G_retracted[:, 1], 'g-', linewidth=1.5, label='r∘G')
    axes[1].set_aspect('equal'); axes[1].set_title('Step 2: Retract')
    axes[1].legend(); axes[1].grid(True, alpha=0.3)

    err_a = np.linalg.norm(F - G_ambient, axis=1)
    err_r = np.linalg.norm(F - G_retracted, axis=1)
    axes[2].plot(x, err_a, 'r-', label=f'Ambient (max={np.max(err_a):.4f})')
    axes[2].plot(x, err_r, 'g-', label=f'Retracted (max={np.max(err_r):.4f})')
    axes[2].set_xlabel('x'); axes[2].set_ylabel('Error')
    axes[2].set_title('Error comparison'); axes[2].legend(); axes[2].grid(True, alpha=0.3)

    fig.suptitle('Constrained Approximation via Retraction onto Unit Disk', fontsize=14)
    plt.tight_layout()
    plt.savefig('demos/figures/demo4_retraction.png', dpi=150, bbox_inches='tight')
    plt.close()

    F_ret = disk_retraction(F)
    id_err = np.max(np.linalg.norm(F - F_ret, axis=1))
    print(f"\n  r|_K = id check: {id_err:.2e}")
    print(f"  Ambient error:   {np.max(err_a):.6f}")
    print(f"  Retracted error: {np.max(err_r):.6f}")
    print("  Retraction projects approximant back into constraint set K.\n")


# ─── Demo 5: Convergence Rate Analysis ──────────────────────────────────────

def demo_convergence_rates():
    print("=" * 70)
    print("Demo 5: Convergence Rate Analysis")
    print("=" * 70)

    x = np.linspace(0, 2 * np.pi, 500)
    F = np.column_stack([np.sin(x), np.cos(x), np.sin(2*x)])
    m = 3

    n_terms_list = [2, 4, 8, 12, 16, 20, 30, 40, 60, 80]
    scalar_errors = {i: [] for i in range(m)}
    vector_errors = []

    for n_t in n_terms_list:
        max_err = 0
        for coord in range(m):
            np.random.seed(42 + coord * 1000)
            approx = np.zeros_like(x)
            for k in range(n_t):
                w_k = np.random.randn() * 2
                b_k = np.random.randn() * 3
                basis = eml_logistic_gen(x, w_k, b_k)
                if np.std(basis) > 1e-10:
                    coeff = np.dot(F[:, coord] - approx, basis) / np.dot(basis, basis)
                    approx += coeff * basis
            err = np.max(np.abs(F[:, coord] - approx))
            scalar_errors[coord].append(err)
            max_err = max(max_err, err)
        vector_errors.append(max_err)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    names = [r'$\sin$', r'$\cos$', r'$\sin 2x$']
    colors = ['b', 'r', 'g']
    for i in range(m):
        ax1.semilogy(n_terms_list, scalar_errors[i], f'{colors[i]}o-', label=names[i])
    ax1.semilogy(n_terms_list, vector_errors, 'ko--', linewidth=2, ms=8, label='Vector')
    ax1.set_xlabel('Basis functions'); ax1.set_ylabel('Error')
    ax1.set_title('Convergence: scalar vs vector'); ax1.legend(); ax1.grid(True, alpha=0.3)

    ax2.plot(n_terms_list, vector_errors, 'ko-', ms=8, label='‖F-G‖ (vector)')
    ms = [max(scalar_errors[i][j] for i in range(m)) for j in range(len(n_terms_list))]
    ax2.plot(n_terms_list, ms, 'r^--', ms=8, label='max_i ‖f_i-g_i‖')
    ax2.set_xlabel('Basis functions'); ax2.set_ylabel('Error')
    ax2.set_title('Vector error = max coordinate error'); ax2.legend(); ax2.grid(True, alpha=0.3)

    fig.suptitle('Convergence: Scalar to Vector Lifting', fontsize=14)
    plt.tight_layout()
    plt.savefig('demos/figures/demo5_convergence.png', dpi=150, bbox_inches='tight')
    plt.close()

    print("\n  Error table:")
    print(f"  {'N':>6} | {'sin':>10} | {'cos':>10} | {'sin2x':>10} | {'vector':>10}")
    print(f"  {'-'*6}-+-{'-'*10}-+-{'-'*10}-+-{'-'*10}-+-{'-'*10}")
    for j, n_t in enumerate(n_terms_list):
        print(f"  {n_t:6d} | {scalar_errors[0][j]:10.6f} | {scalar_errors[1][j]:10.6f} | "
              f"{scalar_errors[2][j]:10.6f} | {vector_errors[j]:10.6f}")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("  VECTOR-VALUED EML STONE-WEIERSTRASS: DEMONSTRATIONS")
    print("=" * 70 + "\n")
    demo_coordinatewise_approximation()
    demo_coupled_class()
    demo_softmax_simplex()
    demo_retraction()
    demo_convergence_rates()
    print("=" * 70)
    print("  All demos completed. Figures saved to demos/figures/")
    print("=" * 70)
