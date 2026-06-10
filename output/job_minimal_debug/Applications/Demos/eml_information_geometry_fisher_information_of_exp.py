#!/usr/bin/env python3
"""
Demo: Fisher Information Geometry of EML Statistical Manifolds

Numerical examples demonstrating:
1. The EML log-partition function and its convexity
2. Fisher information matrix computation
3. KL divergence (Bregman divergence) between EML distributions
4. Natural gradient vs Euclidean gradient trajectories
5. The uniform lower bound I_11 >= 1
"""

import numpy as np

# =============================================================================
# EML Log-Partition Function
# =============================================================================

def eml_log_partition(a: float, b: float) -> float:
    """Ψ(a, b) = a²/2 + b²/2 + exp(a)·log(|b| + 1)"""
    return a**2 / 2 + b**2 / 2 + np.exp(a) * np.log(np.abs(b) + 1)


def eml_fisher_11(a: float, b: float) -> float:
    """I₁₁ = ∂²Ψ/∂a² = 1 + exp(a)·log(|b| + 1)"""
    return 1.0 + np.exp(a) * np.log(np.abs(b) + 1)


def eml_activation(a: float, b: float, x: float) -> float:
    """EML activation: exp(a) · log(b·x + 1)"""
    return np.exp(a) * np.log(b * x + 1)


# =============================================================================
# Demo 1: Fisher Information Lower Bound
# =============================================================================

print("=" * 60)
print("Demo 1: Fisher Information I₁₁ ≥ 1 (Uniform Lower Bound)")
print("=" * 60)

test_params = [
    (0.0, 0.0), (1.0, 0.5), (-2.0, 3.0), (5.0, -1.0), (0.0, 100.0),
    (-10.0, 0.01), (3.0, -5.0)
]

print(f"{'a':>8s} {'b':>8s} {'I₁₁':>12s} {'I₁₁ ≥ 1?':>10s}")
print("-" * 40)
for a, b in test_params:
    I11 = eml_fisher_11(a, b)
    print(f"{a:8.2f} {b:8.2f} {I11:12.4f} {'✓' if I11 >= 1.0 else '✗':>10s}")

# =============================================================================
# Demo 2: KL Divergence (Bregman Divergence)
# =============================================================================

print("\n" + "=" * 60)
print("Demo 2: KL Divergence D_KL(θ, θ') ≥ 0 (Gibbs' Inequality)")
print("=" * 60)


def kl_divergence_1d(psi, theta, theta_prime, eps=1e-7):
    """D_KL = Ψ(θ') - Ψ(θ) - Ψ'(θ)(θ' - θ)"""
    psi_deriv = (psi(theta + eps) - psi(theta - eps)) / (2 * eps)
    return psi(theta_prime) - psi(theta) - psi_deriv * (theta_prime - theta)


# Fix b=1 and vary a
psi_b1 = lambda a: eml_log_partition(a, 1.0)

print(f"{'θ':>8s} {'θ\'':>8s} {'D_KL':>12s} {'≥ 0?':>8s}")
print("-" * 38)
for theta, theta_prime in [
    (0.0, 1.0), (1.0, 0.0), (-1.0, 2.0), (0.5, 0.5), (3.0, -1.0)
]:
    d_kl = kl_divergence_1d(psi_b1, theta, theta_prime)
    print(f"{theta:8.2f} {theta_prime:8.2f} {d_kl:12.6f} {'✓' if d_kl >= -1e-10 else '✗':>8s}")

# =============================================================================
# Demo 3: Natural Gradient vs Euclidean Gradient
# =============================================================================

print("\n" + "=" * 60)
print("Demo 3: Natural Gradient vs Euclidean Gradient")
print("=" * 60)

# Optimize f(a) = (a - 2)² using Euclidean vs Natural gradient
# Fisher info I(a) = 1 + exp(a)*log(2) at b=1
a_euclid = 0.0
a_natural = 0.0
lr = 0.1

print(f"{'Step':>5s} {'a_euclid':>12s} {'a_natural':>12s} {'loss_e':>10s} {'loss_n':>10s}")
print("-" * 52)
for step in range(10):
    loss_e = (a_euclid - 2) ** 2
    loss_n = (a_natural - 2) ** 2
    if step % 2 == 0:
        print(f"{step:5d} {a_euclid:12.6f} {a_natural:12.6f} {loss_e:10.6f} {loss_n:10.6f}")

    # Euclidean gradient
    grad_e = 2 * (a_euclid - 2)
    a_euclid -= lr * grad_e

    # Natural gradient: ∇̃ = I⁻¹ · ∇
    grad_n = 2 * (a_natural - 2)
    I_n = eml_fisher_11(a_natural, 1.0)
    a_natural -= lr * grad_n / I_n

print(f"\nFinal: Euclidean a = {a_euclid:.6f}, Natural a = {a_natural:.6f}")
print(f"Target: a = 2.0")

# =============================================================================
# Demo 4: Strict Convexity Verification
# =============================================================================

print("\n" + "=" * 60)
print("Demo 4: Strict Convexity of Ψ(a, b=1)")
print("=" * 60)

a_vals = np.linspace(-3, 3, 7)
print(f"{'a':>8s} {'Ψ(a)':>12s} {'Ψ\'(a)':>12s} {'Ψ\'\'(a)':>12s} {'> 0?':>6s}")
print("-" * 52)
eps = 1e-5
for a in a_vals:
    psi = eml_log_partition(a, 1.0)
    psi_prime = (eml_log_partition(a + eps, 1.0) - eml_log_partition(a - eps, 1.0)) / (2 * eps)
    psi_double = (
        eml_log_partition(a + eps, 1.0) - 2 * eml_log_partition(a, 1.0) + eml_log_partition(a - eps, 1.0)
    ) / eps**2
    print(f"{a:8.2f} {psi:12.4f} {psi_prime:12.4f} {psi_double:12.4f} {'✓' if psi_double > 0 else '✗':>6s}")

# =============================================================================
# Demo 5: Three-Point Identity Verification
# =============================================================================

print("\n" + "=" * 60)
print("Demo 5: Bregman Three-Point Identity")
print("=" * 60)

x, y, z = 1.0, 2.0, 3.0
D_xz = kl_divergence_1d(psi_b1, z, x)
D_xy = kl_divergence_1d(psi_b1, y, x)
D_yz = kl_divergence_1d(psi_b1, z, y)

psi_prime_y = (psi_b1(y + eps) - psi_b1(y - eps)) / (2 * eps)
psi_prime_z = (psi_b1(z + eps) - psi_b1(z - eps)) / (2 * eps)
angle_term = (psi_prime_y - psi_prime_z) * (x - y)

lhs = D_xz
rhs = D_xy + D_yz + angle_term

print(f"D(x,z) = {lhs:.8f}")
print(f"D(x,y) + D(y,z) + angle = {rhs:.8f}")
print(f"Difference: {abs(lhs - rhs):.2e}")
print(f"Three-point identity holds: {'✓' if abs(lhs - rhs) < 1e-6 else '✗'}")

print("\n" + "=" * 60)
print("All demos complete.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Bregman Divergence and Dual Geometry

Shows the Bregman divergence D_Ψ(θ, θ') as a surface plot,
demonstrating the non-negativity (Gibbs' inequality) and the
three-point identity that underlies the Pythagorean theorem
of information geometry.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D


def eml_log_partition_1d(a: float, b: float = 1.0) -> float:
    return a**2 / 2 + b**2 / 2 + np.exp(a) * np.log(np.abs(b) + 1)


def eml_log_partition_deriv(a: float, b: float = 1.0) -> float:
    return a + np.exp(a) * np.log(np.abs(b) + 1)


def bregman_div(theta: float, theta_prime: float, b: float = 1.0) -> float:
    psi = lambda a: eml_log_partition_1d(a, b)
    psi_deriv = eml_log_partition_deriv(theta_prime, b)
    return psi(theta) - psi(theta_prime) - psi_deriv * (theta - theta_prime)


fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: Bregman divergence surface
theta_range = np.linspace(-2, 3, 100)
theta_prime_range = np.linspace(-2, 3, 100)
T, TP = np.meshgrid(theta_range, theta_prime_range)
D = np.vectorize(bregman_div)(T, TP)

im1 = axes[0].pcolormesh(T, TP, np.log10(np.clip(D, 1e-10, None)), cmap='magma', shading='auto')
axes[0].set_xlabel('θ')
axes[0].set_ylabel("θ'")
axes[0].set_title("log₁₀ D_Ψ(θ, θ') — Bregman Divergence")
plt.colorbar(im1, ax=axes[0])
axes[0].plot(theta_range, theta_range, 'w--', linewidth=1, label='θ = θ\'')
axes[0].legend(loc='upper left')

# Plot 2: Cross-section showing convexity
axes[1].set_xlabel('θ')
axes[1].set_ylabel('Ψ(θ)')
axes[1].set_title('Log-Partition and Tangent Lines')

a_vals = np.linspace(-2, 3, 200)
psi_vals = [eml_log_partition_1d(a) for a in a_vals]
axes[1].plot(a_vals, psi_vals, 'b-', linewidth=2, label='Ψ(θ)')

# Show tangent lines at a few points demonstrating convexity
for theta0 in [0.0, 1.0, 2.0]:
    psi0 = eml_log_partition_1d(theta0)
    dpsi0 = eml_log_partition_deriv(theta0)
    tangent = [psi0 + dpsi0 * (a - theta0) for a in a_vals]
    axes[1].plot(a_vals, tangent, '--', linewidth=1, alpha=0.7)
    axes[1].plot(theta0, psi0, 'ro', markersize=6)

axes[1].set_ylim(-1, 15)
axes[1].legend()
axes[1].set_title('Convexity: Ψ ≥ tangent line (Gibbs)')

# Plot 3: Three-point identity
axes[2].set_xlabel('y (middle point)')
axes[2].set_ylabel('Divergence')
axes[2].set_title('Three-Point Identity Verification')

x, z = 0.0, 2.5
y_vals = np.linspace(-1, 3, 100)
D_xz_vals = [bregman_div(x, z) for _ in y_vals]
D_xy_vals = [bregman_div(x, y) for y in y_vals]
D_yz_vals = [bregman_div(y, z) for y in y_vals]

angle_vals = [
    (eml_log_partition_deriv(y) - eml_log_partition_deriv(z)) * (x - y)
    for y in y_vals
]
rhs_vals = [d1 + d2 + a for d1, d2, a in zip(D_xy_vals, D_yz_vals, angle_vals)]

axes[2].plot(y_vals, D_xz_vals, 'b-', linewidth=2, label='D(x,z)')
axes[2].plot(y_vals, rhs_vals, 'r--', linewidth=2, label='D(x,y)+D(y,z)+angle')
axes[2].axvline(x=x, color='gray', linestyle=':', alpha=0.5, label=f'x={x}')
axes[2].axvline(x=z, color='gray', linestyle=':', alpha=0.5, label=f'z={z}')
axes[2].legend()

plt.tight_layout()
plt.savefig('bregman_geometry.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved bregman_geometry.png")


#!/usr/bin/env python3
"""
Visualization: Fisher Information Landscape of the EML Manifold

Creates a heatmap of the Fisher information I₁₁(a, b) = 1 + exp(a)·log(|b|+1)
showing the Riemannian geometry of the EML parameter space.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib import cm


def eml_fisher_11(a: float, b: float) -> float:
    return 1.0 + np.exp(a) * np.log(np.abs(b) + 1)


def eml_log_partition(a: float, b: float) -> float:
    return a**2 / 2 + b**2 / 2 + np.exp(a) * np.log(np.abs(b) + 1)


# Create grid
a_vals = np.linspace(-3, 3, 200)
b_vals = np.linspace(-3, 3, 200)
A, B = np.meshgrid(a_vals, b_vals)

# Compute Fisher information
I11 = 1.0 + np.exp(A) * np.log(np.abs(B) + 1)

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: Fisher Information I₁₁
im1 = axes[0].pcolormesh(A, B, np.log10(I11), cmap='inferno', shading='auto')
axes[0].set_xlabel('a (exp parameter)')
axes[0].set_ylabel('b (log parameter)')
axes[0].set_title('log₁₀ I₁₁(a, b) — Fisher Information')
plt.colorbar(im1, ax=axes[0], label='log₁₀(I₁₁)')
axes[0].contour(A, B, I11, levels=[1, 2, 5, 10, 50, 100], colors='white', linewidths=0.5)

# Plot 2: Log-partition function
Psi = eml_log_partition(A, B)
im2 = axes[1].pcolormesh(A, B, np.log10(np.clip(Psi, 0.01, None)), cmap='viridis', shading='auto')
axes[1].set_xlabel('a')
axes[1].set_ylabel('b')
axes[1].set_title('log₁₀ Ψ(a, b) — Log-Partition')
plt.colorbar(im2, ax=axes[1], label='log₁₀(Ψ)')

# Plot 3: Natural gradient flow lines
axes[2].set_xlabel('a')
axes[2].set_ylabel('b')
axes[2].set_title('Natural Gradient Flow on EML Manifold')

# Draw flow lines from multiple starting points
for a0 in np.linspace(-2.5, 2.5, 8):
    for b0 in np.linspace(-2.5, 2.5, 8):
        # Target: minimize Ψ
        a_traj, b_traj = [a0], [b0]
        a_cur, b_cur = a0, b0
        lr = 0.02
        for _ in range(30):
            # Euclidean gradient of Ψ
            ga = a_cur + np.exp(a_cur) * np.log(np.abs(b_cur) + 1)
            sign_b = np.sign(b_cur) if b_cur != 0 else 0
            gb = b_cur + np.exp(a_cur) * sign_b / (np.abs(b_cur) + 1)
            # Fisher info I₁₁
            I = 1.0 + np.exp(a_cur) * np.log(np.abs(b_cur) + 1)
            # Natural gradient (1D in a direction)
            a_cur -= lr * ga / max(I, 0.1)
            b_cur -= lr * gb
            a_traj.append(a_cur)
            b_traj.append(b_cur)
        axes[2].plot(a_traj, b_traj, 'b-', alpha=0.3, linewidth=0.5)
        axes[2].plot(a_traj[0], b_traj[0], 'ro', markersize=2)

axes[2].set_xlim(-3, 3)
axes[2].set_ylim(-3, 3)

plt.tight_layout()
plt.savefig('fisher_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved fisher_landscape.png")


#!/usr/bin/env python3
"""
Visualization: Natural Gradient Descent vs Euclidean Gradient Descent
on the EML Fisher Manifold

Compares optimization trajectories under Euclidean and natural gradient
methods, demonstrating how the Fisher metric reshapes the loss landscape.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def eml_fisher_11(a: float, b: float = 1.0) -> float:
    return 1.0 + np.exp(a) * np.log(np.abs(b) + 1)


def loss_fn(a: float) -> float:
    """Non-quadratic loss with EML structure."""
    return (a - 1.5)**2 + 0.5 * np.sin(3 * a)


def loss_grad(a: float) -> float:
    return 2 * (a - 1.5) + 1.5 * np.cos(3 * a)


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Run optimization
lr = 0.05
n_steps = 60

traj_euclid = [0.0]
traj_natural = [0.0]
a_e, a_n = 0.0, 0.0

for _ in range(n_steps):
    g_e = loss_grad(a_e)
    a_e -= lr * g_e
    traj_euclid.append(a_e)

    g_n = loss_grad(a_n)
    I_n = eml_fisher_11(a_n)
    a_n -= lr * g_n / I_n
    traj_natural.append(a_n)

# Plot 1: Loss landscape with trajectories
a_range = np.linspace(-2, 4, 300)
loss_vals = [loss_fn(a) for a in a_range]

axes[0, 0].plot(a_range, loss_vals, 'k-', linewidth=2, label='L(a)')
axes[0, 0].plot(traj_euclid, [loss_fn(a) for a in traj_euclid], 'b.-',
                markersize=4, linewidth=1, label='Euclidean GD', alpha=0.7)
axes[0, 0].plot(traj_natural, [loss_fn(a) for a in traj_natural], 'r.-',
                markersize=4, linewidth=1, label='Natural GD', alpha=0.7)
axes[0, 0].set_xlabel('a')
axes[0, 0].set_ylabel('Loss')
axes[0, 0].set_title('Optimization Trajectories')
axes[0, 0].legend()

# Plot 2: Convergence comparison
axes[0, 1].semilogy(
    [loss_fn(a) for a in traj_euclid], 'b-', label='Euclidean GD'
)
axes[0, 1].semilogy(
    [loss_fn(a) for a in traj_natural], 'r-', label='Natural GD'
)
axes[0, 1].set_xlabel('Step')
axes[0, 1].set_ylabel('Loss (log scale)')
axes[0, 1].set_title('Convergence Rate Comparison')
axes[0, 1].legend()
axes[0, 1].grid(True, alpha=0.3)

# Plot 3: Fisher information along trajectory
axes[1, 0].plot([eml_fisher_11(a) for a in traj_euclid], 'b-', label='Euclidean path')
axes[1, 0].plot([eml_fisher_11(a) for a in traj_natural], 'r-', label='Natural path')
axes[1, 0].axhline(y=1, color='gray', linestyle='--', alpha=0.5, label='Lower bound (I ≥ 1)')
axes[1, 0].set_xlabel('Step')
axes[1, 0].set_ylabel('Fisher Information I₁₁')
axes[1, 0].set_title('Fisher Information Along Trajectories')
axes[1, 0].legend()
axes[1, 0].set_yscale('log')
axes[1, 0].grid(True, alpha=0.3)

# Plot 4: Effective step size (natural gradient norm)
eff_steps_e = [abs(traj_euclid[i+1] - traj_euclid[i]) for i in range(len(traj_euclid)-1)]
eff_steps_n = [abs(traj_natural[i+1] - traj_natural[i]) for i in range(len(traj_natural)-1)]

axes[1, 1].plot(eff_steps_e, 'b-', label='Euclidean step size')
axes[1, 1].plot(eff_steps_n, 'r-', label='Natural step size')
axes[1, 1].set_xlabel('Step')
axes[1, 1].set_ylabel('|Δa|')
axes[1, 1].set_title('Effective Step Sizes')
axes[1, 1].legend()
axes[1, 1].grid(True, alpha=0.3)

plt.suptitle('Natural Gradient Descent on the EML Fisher Manifold', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('ngd_comparison.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved ngd_comparison.png")
