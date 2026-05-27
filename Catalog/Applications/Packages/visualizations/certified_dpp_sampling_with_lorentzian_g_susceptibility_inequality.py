"""
Visualization: DPP Susceptibility / Covariance Quadratic Form

This script visualizes the susceptibility inequality Q(a) ≤ 0 for
DPP kernels with nonneg weight vectors. It shows:
1. The covariance quadratic form as a function of weight direction
2. The identity Q(a) = -∑ a_i a_j K_ij² (Hadamard connection)
3. How perturbation affects the susceptibility bound

CRITICAL: This script is fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt


def make_psd_contraction(n, seed=42):
    rng = np.random.RandomState(seed)
    A = rng.randn(n, n)
    K = A @ A.T / (2 * n)
    eigvals, eigvecs = np.linalg.eigh(K)
    eigvals = np.clip(eigvals, 0, 1)
    K = eigvecs @ np.diag(eigvals) @ eigvecs.T
    return (K + K.T) / 2


def covariance_quad_form(K, a):
    n = K.shape[0]
    Q = 0.0
    for i in range(n):
        for j in range(n):
            pair = K[i,i]*K[j,j] - K[i,j]*K[j,i]
            single_prod = K[i,i] * K[j,j]
            Q += a[i] * a[j] * (pair - single_prod)
    return Q


def hadamard_sum(K, a):
    n = K.shape[0]
    return sum(a[i]*a[j]*K[i,j]*K[j,i] for i in range(n) for j in range(n))


# Setup
n = 5
K = make_psd_contraction(n, seed=42)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Q(a) for varying nonneg weight vectors (parameterized by angle)
ax = axes[0]
thetas = np.linspace(0, np.pi/2, 100)
Qs = []
for theta in thetas:
    # Parameterize nonneg vectors in 2D subspace
    a = np.zeros(n)
    a[0] = np.cos(theta)
    a[1] = np.sin(theta)
    a[2] = 0.5
    a[3] = 0.3
    a[4] = 0.1
    Qs.append(covariance_quad_form(K, a))

ax.plot(np.degrees(thetas), Qs, 'b-', linewidth=2)
ax.axhline(y=0, color='red', linestyle='--', alpha=0.7, label='Q = 0')
ax.fill_between(np.degrees(thetas), Qs, 0, where=[q <= 0 for q in Qs],
                alpha=0.2, color='green', label='Q ≤ 0 (certified)')
ax.set_xlabel('Weight angle θ (degrees)', fontsize=11)
ax.set_ylabel('Q(a)', fontsize=11)
ax.set_title('Susceptibility Q(a) ≤ 0\n(nonneg weights)', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 2: Q vs -Hadamard (identity verification)
ax = axes[1]
rng = np.random.RandomState(0)
Q_values = []
H_values = []
for _ in range(200):
    a = np.abs(rng.randn(n))  # nonneg
    Q_values.append(covariance_quad_form(K, a))
    H_values.append(-hadamard_sum(K, a))

ax.scatter(Q_values, H_values, c='purple', alpha=0.5, s=20)
lims = [min(min(Q_values), min(H_values)), max(max(Q_values), max(H_values))]
ax.plot(lims, lims, 'r--', linewidth=1.5, label='Q = -∑aᵢaⱼKᵢⱼ²')
ax.set_xlabel('Q(a) = covarianceQuadForm', fontsize=11)
ax.set_ylabel('-∑ aᵢaⱼKᵢⱼKⱼᵢ', fontsize=11)
ax.set_title('Covariance Identity\nQ(a) = -∑aᵢaⱼKᵢⱼ²', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 3: Susceptibility under perturbation
ax = axes[2]
etas_sweep = np.linspace(0, 0.08, 40)
Q_exact_list = []
Q_perturbed_list = []
bound_list = []

a_test = np.array([1, 2, 1.5, 0.8, 1.2])

for eta in etas_sweep:
    rng = np.random.RandomState(123)
    noise = rng.uniform(-eta, eta, (n, n))
    noise = (noise + noise.T) / 2
    K_prime = K + noise

    Q_exact_list.append(covariance_quad_form(K, a_test))
    Q_perturbed_list.append(covariance_quad_form(K_prime, a_test))

    M = max(np.max(np.abs(K)), np.max(np.abs(K_prime)))
    bound_list.append(np.sum(a_test)**2 * (2*M + eta) * eta)

ax.plot(etas_sweep, Q_exact_list, 'b-', linewidth=2, label='Q(a) exact K')
ax.plot(etas_sweep, Q_perturbed_list, 'orange', linewidth=2, label="Q(a) perturbed K'")
ax.plot(etas_sweep, bound_list, 'r--', linewidth=2, label='Certified upper bound')
ax.axhline(y=0, color='gray', linestyle=':', alpha=0.5)
ax.set_xlabel('Perturbation η', fontsize=11)
ax.set_ylabel('Q(a)', fontsize=11)
ax.set_title('Approximate Susceptibility\nBound', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_susceptibility.png', dpi=150, bbox_inches='tight')
print("Saved: viz_susceptibility.png")
