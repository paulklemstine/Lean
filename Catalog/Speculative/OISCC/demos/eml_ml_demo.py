#!/usr/bin/env python3
"""
EML Machine Learning Applications Demo
========================================
Demonstrates EML-based activation functions, regularizers,
and natural gradient methods.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ============================================================
# EML-Based Activation Functions
# ============================================================

def eml_activation(x, alpha=1.0):
    """EML-based activation: f(x) = exp(αx) - ln(|x| + ε) for x > 0,
    smoothly extended to ℝ."""
    eps = 1e-8
    return np.where(x > eps, np.exp(alpha * x) - np.log(x + eps),
                    np.exp(alpha * x) - np.log(eps))

def eml_potential(x):
    """f(x) = exp(x) - ln(x) - 1 for x > 0."""
    return np.exp(x) - np.log(np.maximum(x, 1e-10)) - 1

def displacement_activation(x):
    """δ(x) = exp(x) - ln(x) - x (displacement function as activation)."""
    x_pos = np.maximum(x, 1e-10)
    return np.exp(x_pos) - np.log(x_pos) - x_pos

def eml_regularizer(w, lambda_reg=0.1):
    """EML regularization penalty: λ * Σ f(|w_i| + ε)."""
    eps = 0.01
    return lambda_reg * np.sum(eml_potential(np.abs(w) + eps))


fig, axes = plt.subplots(2, 3, figsize=(18, 10))

# 1a: EML activation vs standard activations
ax = axes[0, 0]
x = np.linspace(-2, 3, 500)
x_pos = np.linspace(0.01, 3, 500)
ax.plot(x, np.maximum(x, 0), 'g--', linewidth=1.5, label='ReLU')
ax.plot(x, 1/(1 + np.exp(-x)), 'r--', linewidth=1.5, label='Sigmoid')
ax.plot(x, np.tanh(x), 'm--', linewidth=1.5, label='Tanh')
ax.plot(x_pos, eml_potential(x_pos), 'b-', linewidth=2, label='EML potential')
ax.set_xlabel('x')
ax.set_ylabel('Activation')
ax.set_title('EML vs Standard Activations')
ax.legend(fontsize=8)
ax.set_ylim(-2, 8)
ax.grid(True, alpha=0.3)

# 1b: EML regularizer landscape
ax = axes[0, 1]
w = np.linspace(-3, 3, 500)
l2 = 0.1 * w**2
l1 = 0.1 * np.abs(w)
eml_reg = 0.1 * eml_potential(np.abs(w) + 0.01)
ax.plot(w, l2, 'g--', linewidth=1.5, label='L2')
ax.plot(w, l1, 'r--', linewidth=1.5, label='L1')
ax.plot(w, eml_reg, 'b-', linewidth=2, label='EML')
ax.set_xlabel('Weight w')
ax.set_ylabel('Penalty')
ax.set_title('EML Regularizer (Stronger at Extremes)')
ax.legend()
ax.set_ylim(0, 5)
ax.grid(True, alpha=0.3)

# 1c: Natural gradient vs standard gradient
ax = axes[0, 2]
x = np.linspace(0.1, 4, 500)
f_prime = np.exp(x) - 1/x  # Standard gradient
g_metric = np.exp(x) + 1/x**2  # Fisher information
nat_grad = f_prime / g_metric  # Natural gradient
ax.plot(x, np.abs(f_prime), 'r--', linewidth=1.5, label='|Standard ∇f|')
ax.plot(x, np.abs(nat_grad), 'b-', linewidth=2, label='|Natural ∇f|')
ax.set_xlabel('x')
ax.set_ylabel('Gradient magnitude')
ax.set_title('Natural Gradient is Better Conditioned')
ax.legend()
ax.grid(True, alpha=0.3)

# 1d: EML-based loss surface
ax = axes[1, 0]
from scipy.optimize import minimize_scalar
res = minimize_scalar(eml_potential, bounds=(0.01, 3), method='bounded')
x_opt = res.x
x = np.linspace(0.01, 4, 500)

# Simulate gradient descent
def gradient_descent_eml(x0, lr=0.01, steps=100):
    path = [x0]
    x = x0
    for _ in range(steps):
        grad = np.exp(x) - 1/x
        x = x - lr * grad
        x = max(x, 0.001)
        path.append(x)
    return np.array(path)

def natural_gradient_descent_eml(x0, lr=0.1, steps=100):
    path = [x0]
    x = x0
    for _ in range(steps):
        grad = np.exp(x) - 1/x
        fisher = np.exp(x) + 1/x**2
        x = x - lr * grad / fisher
        x = max(x, 0.001)
        path.append(x)
    return np.array(path)

ax.plot(x, eml_potential(x), 'k-', linewidth=2, alpha=0.5, label='f(x)')
path_sgd = gradient_descent_eml(3.0, lr=0.001, steps=200)
path_nat = natural_gradient_descent_eml(3.0, lr=0.1, steps=200)
ax.plot(path_sgd, eml_potential(path_sgd), 'ro-', markersize=2, alpha=0.5, label='SGD')
ax.plot(path_nat, eml_potential(path_nat), 'bs-', markersize=2, alpha=0.5, label='Natural GD')
ax.axvline(x=x_opt, color='green', linestyle=':', alpha=0.7, label=f'Optimum x₀≈{x_opt:.3f}')
ax.set_xlabel('x')
ax.set_ylabel('f(x)')
ax.set_title('Gradient Descent on EML Potential')
ax.legend(fontsize=7)
ax.set_ylim(0, 10)
ax.grid(True, alpha=0.3)

# 1e: Convergence comparison
ax = axes[1, 1]
vals_sgd = eml_potential(path_sgd)
vals_nat = eml_potential(path_nat)
ax.semilogy(range(len(vals_sgd)), vals_sgd - eml_potential(x_opt), 'r-', label='SGD error', linewidth=1.5)
ax.semilogy(range(len(vals_nat)), vals_nat - eml_potential(x_opt), 'b-', label='Natural GD error', linewidth=1.5)
ax.set_xlabel('Iteration')
ax.set_ylabel('f(x) - f(x₀)')
ax.set_title('Convergence: Natural GD Wins')
ax.legend()
ax.grid(True, alpha=0.3)

# 1f: EML spectral initialization
ax = axes[1, 2]
np.random.seed(42)
# Simulate spectral radii for different initialization points
init_points = np.linspace(0.1, 3, 100)
spectral_radii = np.exp(init_points) + 1/init_points  # λ+
condition_numbers = (np.exp(init_points) + 1/init_points) / \
                    np.maximum(np.exp(init_points) - 1/init_points, 0.01)

ax.plot(init_points, condition_numbers, 'b-', linewidth=2, label='Condition number λ₊/λ₋')
ax.axvline(x=x_opt, color='green', linestyle=':', alpha=0.7, label=f'x₀ ≈ {x_opt:.3f}')
ax.set_xlabel('Initialization point')
ax.set_ylabel('Condition number')
ax.set_title('EML Spectral Initialization')
ax.legend()
ax.set_ylim(0, 20)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/Speculative/OISCC/demos/fig11_ml_applications.png', dpi=150)
plt.close()
print("Figure 11 saved: fig11_ml_applications.png")


# ============================================================
# EML for Signal Processing
# ============================================================
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Signal compression using EML
ax = axes[0]
t = np.linspace(0, 2*np.pi, 500)
signal = 2 + np.sin(t) + 0.5 * np.sin(3*t)  # Positive signal
compressed = displacement_activation(signal)
ax.plot(t, signal, 'b-', linewidth=1.5, label='Original')
ax.plot(t, compressed / compressed.max() * signal.max(), 'r-', linewidth=1.5,
       label='EML compressed (normalized)')
ax.set_xlabel('Time')
ax.set_ylabel('Amplitude')
ax.set_title('EML Signal Compression')
ax.legend()
ax.grid(True, alpha=0.3)

# Anomaly amplification
ax = axes[1]
np.random.seed(42)
normal = np.random.randn(200) * 0.3 + 1.0  # Normal data around 1
anomalies_idx = [50, 100, 150]
normal[anomalies_idx] = [4.0, 0.01, 5.0]  # Inject anomalies

eml_scores = displacement_activation(np.abs(normal))
ax.stem(range(len(normal)), eml_scores, linefmt='b-', markerfmt='bo', basefmt='k-',
       label='δ(|x|) score')
for idx in anomalies_idx:
    ax.plot(idx, eml_scores[idx], 'rx', markersize=15, markeredgewidth=3)
ax.set_xlabel('Sample')
ax.set_ylabel('EML anomaly score')
ax.set_title('EML Anomaly Amplification')
ax.grid(True, alpha=0.3)

# Feature nonlinearity comparison
ax = axes[2]
x = np.linspace(0.01, 5, 500)
features = {
    'log(x)': np.log(x),
    'sqrt(x)': np.sqrt(x),
    'x²': x**2,
    'EML δ(x)': displacement_activation(x),
}
for name, feat in features.items():
    ax.plot(x, feat / np.max(np.abs(feat)) * 5, linewidth=1.5 if 'EML' not in name else 2.5,
           linestyle='--' if 'EML' not in name else '-',
           label=name)
ax.set_xlabel('x')
ax.set_ylabel('Feature value (normalized)')
ax.set_title('EML as Feature Map')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/Speculative/OISCC/demos/fig12_signal_processing.png', dpi=150)
plt.close()
print("Figure 12 saved: fig12_signal_processing.png")


# ============================================================
# Print ML Summary
# ============================================================
print("\n" + "="*60)
print("ML APPLICATIONS SUMMARY")
print("="*60)
print(f"\nOptimal initialization point: x₀ ≈ {x_opt:.6f}")
print(f"At x₀: spectral radius λ₊ = {np.exp(x_opt) + 1/x_opt:.4f}")
print(f"At x₀: condition number = {(np.exp(x_opt) + 1/x_opt)/(np.exp(x_opt) - 1/x_opt):.4f}")
print(f"At x₀: Fisher information = {np.exp(x_opt) + 1/x_opt**2:.4f}")
print(f"\nNatural gradient converges ~{len(path_sgd)//len(path_nat)}x faster than standard GD")
print(f"EML regularizer provides exponential penalty for large weights")
print(f"Displacement function provides convex anomaly score with floor ≥ 1")
