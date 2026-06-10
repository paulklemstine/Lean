#!/usr/bin/env python3
"""
EML Universal Approximation Demo
=================================

Demonstrates the EML Stone–Weierstrass theorem: any continuous function on a compact
domain can be uniformly approximated by EML (Exponential-Multiplicative-Logarithmic)
expressions. We show this concretely by approximating several target functions using
sums/products of exp(w·x + b) generators.

Usage:
    python demo_eml_approximation.py
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import minimize


# --- EML Generators ---

def eml_exp_generator(x, w, b):
    """exp(w·x + b) — the core EML generator."""
    return np.exp(np.dot(x, w) + b)


def eml_network(x, params, n_terms):
    """
    A finite EML approximator: linear combination of exp generators.
    f(x) = c_0 + sum_{j=1}^{n_terms} c_j * exp(w_j * x + b_j)
    
    params layout: [c_0, c_1, w_1, b_1, c_2, w_2, b_2, ...]
    """
    c0 = params[0]
    result = c0 * np.ones_like(x)
    idx = 1
    for _ in range(n_terms):
        c_j = params[idx]
        w_j = params[idx + 1]
        b_j = params[idx + 2]
        result = result + c_j * np.exp(w_j * x + b_j)
        idx += 3
    return result


def fit_eml(target_fn, x_train, n_terms=5, n_restarts=5):
    """Fit an EML approximator to a target function on training points."""
    y_train = target_fn(x_train)
    n_params = 1 + 3 * n_terms
    
    best_params = None
    best_loss = np.inf
    
    for _ in range(n_restarts):
        p0 = np.random.randn(n_params) * 0.5
        
        def loss(p):
            try:
                pred = eml_network(x_train, p, n_terms)
                return np.mean((pred - y_train) ** 2)
            except (OverflowError, FloatingPointError):
                return 1e10
        
        res = minimize(loss, p0, method='L-BFGS-B', 
                       options={'maxiter': 2000, 'ftol': 1e-15})
        if res.fun < best_loss:
            best_loss = res.fun
            best_params = res.x
    
    return best_params, best_loss


# --- Target functions to approximate ---

def target_sin(x):
    return np.sin(2 * np.pi * x)

def target_abs(x):
    return np.abs(x - 0.5)

def target_step(x):
    return np.where(x > 0.5, 1.0, 0.0)

def target_poly(x):
    return 4 * x * (1 - x)

def target_composite(x):
    return np.sin(4 * np.pi * x) * np.exp(-2 * x)


# --- Main demo ---

def main():
    np.random.seed(42)
    
    targets = [
        ("sin(2πx)", target_sin),
        ("|x - 0.5|", target_abs),
        ("4x(1-x)", target_poly),
        ("sin(4πx)·e^{-2x}", target_composite),
    ]
    
    x_train = np.linspace(0, 1, 200)
    x_test = np.linspace(0, 1, 500)
    
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    fig.suptitle(
        "EML Universal Approximation: Stone–Weierstrass in Action",
        fontsize=14, fontweight='bold'
    )
    
    term_counts = [3, 5, 10]
    colors = ['#e74c3c', '#3498db', '#2ecc71']
    
    for idx, (name, fn) in enumerate(targets):
        ax = axes[idx // 2][idx % 2]
        y_test = fn(x_test)
        ax.plot(x_test, y_test, 'k-', linewidth=2, label=f'Target: {name}')
        
        for n_terms, color in zip(term_counts, colors):
            params, loss = fit_eml(fn, x_train, n_terms=n_terms, n_restarts=3)
            y_pred = eml_network(x_test, params, n_terms)
            sup_err = np.max(np.abs(y_pred - y_test))
            ax.plot(x_test, y_pred, '--', color=color, linewidth=1.5,
                    label=f'EML ({n_terms} terms), ε={sup_err:.4f}')
        
        ax.set_xlabel('x')
        ax.set_ylabel('f(x)')
        ax.set_title(f'Approximating {name}')
        ax.legend(fontsize=8, loc='best')
        ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('eml_approximation_demo.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved eml_approximation_demo.png")
    
    # --- Convergence demo ---
    fig2, ax2 = plt.subplots(figsize=(8, 5))
    max_terms = 15
    errors = []
    
    for n in range(1, max_terms + 1):
        params, loss = fit_eml(target_sin, x_train, n_terms=n, n_restarts=3)
        y_pred = eml_network(x_test, params, n)
        sup_err = np.max(np.abs(y_pred - target_sin(x_test)))
        errors.append(sup_err)
        print(f"  {n:2d} EML terms → sup-error = {sup_err:.6f}")
    
    ax2.semilogy(range(1, max_terms + 1), errors, 'bo-', linewidth=2, markersize=6)
    ax2.set_xlabel('Number of EML generators', fontsize=12)
    ax2.set_ylabel('Supremum error ‖f - f_EML‖∞', fontsize=12)
    ax2.set_title('Convergence of EML Approximation to sin(2πx)', fontsize=13)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('eml_convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved eml_convergence.png")
    
    # --- 2D demo ---
    print("\n--- 2D Approximation Demo ---")
    
    def target_2d(xy):
        x, y = xy[:, 0], xy[:, 1]
        return np.sin(2 * np.pi * x) * np.cos(2 * np.pi * y)
    
    grid = np.linspace(0, 1, 30)
    xx, yy = np.meshgrid(grid, grid)
    xy_train = np.column_stack([xx.ravel(), yy.ravel()])
    z_true = target_2d(xy_train).reshape(xx.shape)
    
    # Fit 2D EML
    n_terms_2d = 15
    n_params_2d = 1 + 4 * n_terms_2d  # c_0, then (c_j, w1_j, w2_j, b_j)
    z_train = target_2d(xy_train)
    
    def eml_2d(xy, params, n_terms):
        result = params[0] * np.ones(xy.shape[0])
        idx = 1
        for _ in range(n_terms):
            c = params[idx]
            w1 = params[idx + 1]
            w2 = params[idx + 2]
            b = params[idx + 3]
            result += c * np.exp(w1 * xy[:, 0] + w2 * xy[:, 1] + b)
            idx += 4
        return result
    
    best_p, best_l = None, np.inf
    for _ in range(5):
        p0 = np.random.randn(n_params_2d) * 0.3
        def loss_2d(p):
            try:
                return np.mean((eml_2d(xy_train, p, n_terms_2d) - z_train) ** 2)
            except:
                return 1e10
        res = minimize(loss_2d, p0, method='L-BFGS-B', options={'maxiter': 3000})
        if res.fun < best_l:
            best_l = res.fun
            best_p = res.x
    
    z_pred = eml_2d(xy_train, best_p, n_terms_2d).reshape(xx.shape)
    
    fig3, (ax3a, ax3b, ax3c) = plt.subplots(1, 3, figsize=(15, 4))
    
    im1 = ax3a.contourf(xx, yy, z_true, levels=20, cmap='RdBu_r')
    ax3a.set_title('Target: sin(2πx)cos(2πy)')
    plt.colorbar(im1, ax=ax3a)
    
    im2 = ax3b.contourf(xx, yy, z_pred, levels=20, cmap='RdBu_r')
    ax3b.set_title(f'EML Approximation ({n_terms_2d} terms)')
    plt.colorbar(im2, ax=ax3b)
    
    im3 = ax3c.contourf(xx, yy, np.abs(z_true - z_pred), levels=20, cmap='hot_r')
    ax3c.set_title(f'|Error| (max={np.max(np.abs(z_true - z_pred)):.4f})')
    plt.colorbar(im3, ax=ax3c)
    
    for ax in [ax3a, ax3b, ax3c]:
        ax.set_xlabel('x')
        ax.set_ylabel('y')
    
    plt.tight_layout()
    plt.savefig('eml_2d_approximation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved eml_2d_approximation.png")
    
    print("\n=== Summary ===")
    print("The EML Stone–Weierstrass theorem guarantees that *any* continuous function")
    print("on a compact domain can be uniformly approximated by finite EML expressions.")
    print("The demos above show this convergence empirically for 1D and 2D targets.")


if __name__ == '__main__':
    main()
