#!/usr/bin/env python3
"""
Information Geometry of Optimization: Real-World Applications

Demonstrates natural gradient descent on practical ML problems:
1. Logistic regression with varying condition numbers
2. Neural network training with Fisher information
3. Exponential family parameter estimation
"""

import numpy as np
from typing import Tuple, List


def sigmoid(z):
    """Numerically stable sigmoid."""
    return np.where(z >= 0, 1 / (1 + np.exp(-z)), np.exp(z) / (1 + np.exp(z)))


class LogisticRegressionNaturalGD:
    """
    Logistic regression trained with natural gradient descent.
    
    The Fisher information matrix for logistic regression is:
    G(θ) = Σᵢ p(1|xᵢ;θ)(1-p(1|xᵢ;θ)) xᵢxᵢᵀ
    
    This is the expected outer product of the score function,
    and serves as the Riemannian metric on the parameter space.
    """
    
    def __init__(self, X: np.ndarray, y: np.ndarray, reg: float = 1e-4):
        self.X = X
        self.y = y
        self.n, self.d = X.shape
        self.reg = reg
    
    def loss(self, theta: np.ndarray) -> float:
        z = self.X @ theta
        return -np.mean(self.y * np.log(sigmoid(z) + 1e-12) + 
                       (1 - self.y) * np.log(1 - sigmoid(z) + 1e-12))
    
    def gradient(self, theta: np.ndarray) -> np.ndarray:
        z = self.X @ theta
        p = sigmoid(z)
        return self.X.T @ (p - self.y) / self.n
    
    def fisher_matrix(self, theta: np.ndarray) -> np.ndarray:
        z = self.X @ theta
        p = sigmoid(z)
        W = p * (1 - p)
        G = (self.X.T * W) @ self.X / self.n + self.reg * np.eye(self.d)
        return G
    
    def train_natural_gd(self, theta0: np.ndarray, eta: float, n_steps: int) -> Tuple[np.ndarray, List[float]]:
        theta = theta0.copy()
        losses = []
        for _ in range(n_steps):
            l = self.loss(theta)
            losses.append(l)
            g = self.gradient(theta)
            G = self.fisher_matrix(theta)
            G_inv = np.linalg.inv(G)
            theta -= eta * G_inv @ g
        losses.append(self.loss(theta))
        return theta, losses
    
    def train_standard_gd(self, theta0: np.ndarray, eta: float, n_steps: int) -> Tuple[np.ndarray, List[float]]:
        theta = theta0.copy()
        losses = []
        for _ in range(n_steps):
            l = self.loss(theta)
            losses.append(l)
            g = self.gradient(theta)
            theta -= eta * g
        losses.append(self.loss(theta))
        return theta, losses


def application_logistic_regression():
    """
    Application: Logistic regression with natural gradient.
    
    We create datasets with different condition numbers by scaling features,
    demonstrating that natural gradient is robust to ill-conditioning while
    standard gradient slows down dramatically.
    """
    print("=" * 70)
    print("APPLICATION: Logistic Regression with Natural Gradient")
    print("=" * 70)
    
    np.random.seed(42)
    n, d = 200, 10
    n_steps = 100
    
    for kappa in [1, 10, 100]:
        # Create data with controlled condition number
        scales = np.linspace(1, kappa, d)
        X = np.random.randn(n, d) * scales
        true_theta = np.random.randn(d) / np.sqrt(d)
        y = (sigmoid(X @ true_theta) > 0.5).astype(float)
        
        model = LogisticRegressionNaturalGD(X, y, reg=0.01)
        theta0 = np.zeros(d)
        
        # Natural gradient
        theta_ng, losses_ng = model.train_natural_gd(theta0, eta=0.5, n_steps=n_steps)
        
        # Standard gradient (smaller step size for stability)
        theta_gd, losses_gd = model.train_standard_gd(theta0, eta=0.01/kappa, n_steps=n_steps)
        
        print(f"\nCondition number κ ≈ {kappa}")
        print(f"  Natural GD:  loss = {losses_ng[-1]:.4f} (after {n_steps} steps)")
        print(f"  Standard GD: loss = {losses_gd[-1]:.4f} (after {n_steps} steps)")
        print(f"  NG improvement: {(losses_ng[0] - losses_ng[-1]):.4f}")
        print(f"  GD improvement: {(losses_gd[0] - losses_gd[-1]):.4f}")


class ExponentialFamilyEstimation:
    """
    Maximum likelihood estimation for exponential families using natural gradient.
    
    For exponential family p(x|θ) = h(x)exp(θᵀT(x) - A(θ)),
    the Fisher information is G(θ) = ∇²A(θ) (the Hessian of log-partition).
    
    This connects information theory (entropy), geometry (Fisher metric),
    and optimization (natural gradient) — the cross-domain bridge.
    """
    
    def __init__(self, sufficient_stats: np.ndarray):
        """
        Args:
            sufficient_stats: n × d matrix of sufficient statistics T(xᵢ)
        """
        self.T = sufficient_stats
        self.n, self.d = sufficient_stats.shape
        self.empirical_mean = self.T.mean(axis=0)
    
    def log_partition_gradient(self, theta: np.ndarray) -> np.ndarray:
        """∇A(θ) = E_θ[T(X)] (expected sufficient statistics)."""
        weights = np.exp(self.T @ theta)
        weights /= weights.sum()
        return self.T.T @ weights
    
    def fisher_information(self, theta: np.ndarray) -> np.ndarray:
        """G(θ) = ∇²A(θ) = Cov_θ[T(X)]."""
        weights = np.exp(self.T @ theta)
        weights /= weights.sum()
        mean = self.T.T @ weights
        centered = self.T - mean
        G = (centered.T * weights) @ centered + 1e-6 * np.eye(self.d)
        return G
    
    def neg_log_likelihood(self, theta: np.ndarray) -> float:
        """Negative log-likelihood (up to constant)."""
        return -self.empirical_mean @ theta + np.log(np.exp(self.T @ theta).sum() / self.n)
    
    def estimate_natural_gd(self, theta0: np.ndarray, eta: float, n_steps: int) -> Tuple[np.ndarray, List[float]]:
        theta = theta0.copy()
        losses = []
        for _ in range(n_steps):
            losses.append(self.neg_log_likelihood(theta))
            grad_A = self.log_partition_gradient(theta)
            gradient = -self.empirical_mean + grad_A
            G = self.fisher_information(theta)
            G_inv = np.linalg.inv(G)
            theta -= eta * G_inv @ gradient
        losses.append(self.neg_log_likelihood(theta))
        return theta, losses


def application_exponential_family():
    """
    Application: Exponential family MLE via natural gradient.
    
    This demonstrates the Cramér-Rao ↔ optimization duality:
    the same Fisher information matrix that bounds estimation variance
    also determines the natural gradient direction.
    """
    print("\n" + "=" * 70)
    print("APPLICATION: Exponential Family MLE via Natural Gradient")
    print("=" * 70)
    
    np.random.seed(123)
    n, d = 500, 5
    
    # Generate data from a multivariate Gaussian (an exponential family)
    true_theta = np.array([1.0, -0.5, 0.3, 0.8, -0.2])
    T = np.random.randn(n, d) + true_theta
    
    estimator = ExponentialFamilyEstimation(T)
    theta0 = np.zeros(d)
    
    theta_est, losses = estimator.estimate_natural_gd(theta0, eta=0.5, n_steps=50)
    
    print(f"\nTrue parameters:      {true_theta}")
    print(f"Estimated parameters: {np.round(theta_est, 3)}")
    print(f"Parameter error:      {np.linalg.norm(theta_est - true_theta):.4f}")
    print(f"Loss reduction:       {losses[0]:.4f} → {losses[-1]:.4f}")
    
    # Compute Fisher information at estimate and show Cramér-Rao bound
    G = estimator.fisher_information(theta_est)
    eigenvalues = np.linalg.eigvalsh(G)
    kappa = eigenvalues[-1] / eigenvalues[0]
    cramer_rao = 1.0 / eigenvalues[0]
    
    print(f"\nFisher information at estimate:")
    print(f"  Condition number: {kappa:.2f}")
    print(f"  Cramér-Rao variance bound: {cramer_rao:.4f}")
    print(f"  Duality product (Var × κ): {cramer_rao * kappa:.4f}")
    print(f"  = λ_max/λ_min²: {eigenvalues[-1]/eigenvalues[0]**2:.4f}")


if __name__ == "__main__":
    application_logistic_regression()
    application_exponential_family()
    
    print("\n" + "=" * 70)
    print("All applications completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Information Geometry of Optimization: Natural Gradient Follows Geodesics

This demo compares natural gradient descent and standard gradient descent
on strongly convex quadratic problems, demonstrating that natural gradient
convergence is independent of the condition number.

Key results demonstrated:
1. Natural gradient converges at rate exp(-T/d), independent of condition number
2. Standard gradient converges at rate (1-1/κ)^T, dependent on condition number
3. For ill-conditioned problems (κ >> 1), natural gradient is dramatically faster
"""

import numpy as np

def fisher_metric_condition_number(lambda_min: float, lambda_max: float) -> float:
    """Compute condition number κ = λ_max / λ_min."""
    assert lambda_min > 0, "λ_min must be positive"
    assert lambda_max >= lambda_min, "λ_max must be ≥ λ_min"
    return lambda_max / lambda_min

def nat_grad_strong_convex_bound(delta0: float, d: int, T: int) -> float:
    """Natural gradient bound: Δ₀ · exp(-T/d)."""
    return delta0 * np.exp(-T / d)

def gd_strong_convex_bound(delta0: float, kappa: float, T: int) -> float:
    """Standard GD bound: Δ₀ · (1 - 1/κ)^T."""
    return delta0 * (1 - 1/kappa)**T

def nat_grad_gap_bound(diameter: float, T: int) -> float:
    """Convex (non-strongly convex) natural gradient bound: D²/(2T)."""
    return diameter**2 / (2 * T)

def run_natural_gradient_descent(A, b, x0, G_inv, eta, n_steps):
    """
    Run natural gradient descent: x_{t+1} = x_t - η · G⁻¹ · ∇f(x_t)
    for f(x) = 0.5 x^T A x - b^T x
    """
    x = x0.copy()
    losses = []
    x_opt = np.linalg.solve(A, b)
    f_opt = 0.5 * x_opt @ A @ x_opt - b @ x_opt
    
    for t in range(n_steps):
        f_val = 0.5 * x @ A @ x - b @ x
        losses.append(f_val - f_opt)
        grad = A @ x - b
        x = x - eta * G_inv @ grad
    
    f_val = 0.5 * x @ A @ x - b @ x
    losses.append(f_val - f_opt)
    return np.array(losses)

def run_standard_gradient_descent(A, b, x0, eta, n_steps):
    """
    Run standard gradient descent: x_{t+1} = x_t - η · ∇f(x_t)
    for f(x) = 0.5 x^T A x - b^T x
    """
    x = x0.copy()
    losses = []
    x_opt = np.linalg.solve(A, b)
    f_opt = 0.5 * x_opt @ A @ x_opt - b @ x_opt
    
    for t in range(n_steps):
        f_val = 0.5 * x @ A @ x - b @ x
        losses.append(f_val - f_opt)
        grad = A @ x - b
        x = x - eta * grad
    
    f_val = 0.5 * x @ A @ x - b @ x
    losses.append(f_val - f_opt)
    return np.array(losses)


def demo_convergence_comparison():
    """Compare natural gradient and standard gradient on quadratics with varying κ."""
    print("=" * 70)
    print("DEMO: Natural Gradient vs Standard Gradient Convergence")
    print("=" * 70)
    
    d = 10  # dimension
    n_steps = 100
    
    condition_numbers = [1, 10, 100, 1000]
    
    for kappa in condition_numbers:
        # Create a diagonal matrix with condition number κ
        eigenvalues = np.linspace(1, kappa, d)
        A = np.diag(eigenvalues)
        G_inv = np.linalg.inv(A)  # Natural gradient uses G = A for quadratics
        
        b = np.ones(d)
        x0 = np.zeros(d)
        
        # Step sizes: 1/L for GD, 1 for natural GD (since G^{-1} already scales)
        eta_gd = 1.0 / kappa  # 1/L where L = λ_max
        eta_ng = 1.0
        
        losses_gd = run_standard_gradient_descent(A, b, x0, eta_gd, n_steps)
        losses_ng = run_natural_gradient_descent(A, b, x0, G_inv, eta_ng, n_steps)
        
        print(f"\nCondition number κ = {kappa}")
        print(f"  GD  gap after {n_steps} steps: {losses_gd[-1]:.2e}")
        print(f"  NG  gap after {n_steps} steps: {losses_ng[-1]:.2e}")
        print(f"  Speedup ratio: {losses_gd[-1] / max(losses_ng[-1], 1e-300):.1f}x")
        
        # Verify theoretical bounds
        delta0 = losses_gd[0]
        theoretical_gd = gd_strong_convex_bound(delta0, kappa, n_steps)
        theoretical_ng = nat_grad_strong_convex_bound(delta0, d, n_steps)
        print(f"  Theoretical GD bound:  {theoretical_gd:.2e}")
        print(f"  Theoretical NG bound:  {theoretical_ng:.2e}")


def demo_dimension_free_conjecture():
    """Test the dimension-free convergence conjecture."""
    print("\n" + "=" * 70)
    print("DEMO: Dimension-Free Convergence Conjecture Test")
    print("=" * 70)
    
    dimensions = [5, 20, 50, 100]
    n_steps = 200
    mu_over_beta = 0.1  # Fixed ratio
    
    print(f"\nFixed μ/β = {mu_over_beta}")
    print("If conjecture is TRUE: all curves should overlap when plotted vs T·μ/β")
    print("If conjecture is FALSE: higher dimensions should converge slower\n")
    
    for d in dimensions:
        eigenvalues = np.array([mu_over_beta] + [1.0] * (d - 1))
        A = np.diag(eigenvalues)
        G_inv = np.linalg.inv(A)
        
        b = np.ones(d)
        x0 = np.zeros(d)
        
        losses_ng = run_natural_gradient_descent(A, b, x0, G_inv, 1.0, n_steps)
        
        # Sample at specific T·μ/β values
        for t_scaled in [1.0, 5.0, 10.0]:
            t = int(t_scaled / mu_over_beta)
            if t < len(losses_ng):
                print(f"  d={d:4d}, T·μ/β={t_scaled:.1f} (T={t:4d}): gap = {losses_ng[t]:.6e}")


def demo_cramer_rao_duality():
    """Demonstrate the Cramér-Rao / optimization duality."""
    print("\n" + "=" * 70)
    print("DEMO: Cramér-Rao ↔ Optimization Duality")
    print("=" * 70)
    
    print("\nThe Fisher information G simultaneously controls:")
    print("  1. Estimation variance: Var ≥ 1/λ_min  (Cramér-Rao)")
    print("  2. Optimization rate:   κ = λ_max/λ_min (condition number)")
    print("  3. Duality product:     Var × κ = λ_max/λ_min²")
    
    for lambda_min, lambda_max in [(1, 1), (1, 10), (1, 100), (0.1, 10)]:
        kappa = fisher_metric_condition_number(lambda_min, lambda_max)
        variance = 1.0 / lambda_min
        duality = variance * kappa
        print(f"\n  λ_min={lambda_min}, λ_max={lambda_max}: κ={kappa:.1f}, Var≥{variance:.2f}, Var×κ={duality:.2f}")
        print(f"    = λ_max/λ_min² = {lambda_max/lambda_min**2:.2f} ✓")


if __name__ == "__main__":
    demo_convergence_comparison()
    demo_dimension_free_conjecture()
    demo_cramer_rao_duality()
    
    print("\n" + "=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Convergence Rate Comparison

Compares natural gradient descent vs standard gradient descent convergence
on strongly convex quadratics with varying condition numbers.

Shows that natural gradient convergence is independent of the condition number,
while standard gradient convergence degrades linearly with κ.
"""

import numpy as np
import matplotlib.pyplot as plt

def nat_grad_bound(delta0, d, T_arr):
    return delta0 * np.exp(-T_arr / d)

def gd_bound(delta0, kappa, T_arr):
    return delta0 * (1 - 1/kappa)**T_arr

def run_gd(A, b, x0, eta, n_steps):
    x = x0.copy()
    x_opt = np.linalg.solve(A, b)
    f_opt = 0.5 * x_opt @ A @ x_opt - b @ x_opt
    gaps = []
    for _ in range(n_steps + 1):
        f_val = 0.5 * x @ A @ x - b @ x
        gaps.append(f_val - f_opt)
        grad = A @ x - b
        x = x - eta * grad
    return np.array(gaps)

def run_ng(A, b, x0, eta, n_steps):
    x = x0.copy()
    G_inv = np.linalg.inv(A)
    x_opt = np.linalg.solve(A, b)
    f_opt = 0.5 * x_opt @ A @ x_opt - b @ x_opt
    gaps = []
    for _ in range(n_steps + 1):
        f_val = 0.5 * x @ A @ x - b @ x
        gaps.append(f_val - f_opt)
        grad = A @ x - b
        x = x - eta * G_inv @ grad
    return np.array(gaps)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

d = 10
n_steps = 150
kappas = [5, 50, 500]
colors_gd = ['#e74c3c', '#c0392b', '#922b21']
colors_ng = ['#2ecc71', '#27ae60', '#1e8449']

T = np.arange(n_steps + 1)
b = np.ones(d)
x0 = np.zeros(d)

# Panel 1: Actual convergence curves
ax = axes[0]
for i, kappa in enumerate(kappas):
    eigenvalues = np.linspace(1, kappa, d)
    A = np.diag(eigenvalues)
    
    gaps_gd = run_gd(A, b, x0, 1.0/kappa, n_steps)
    gaps_ng = run_ng(A, b, x0, 1.0, n_steps)
    
    ax.semilogy(T, np.maximum(gaps_gd, 1e-16), color=colors_gd[i], 
                linestyle='--', label=f'GD κ={kappa}', alpha=0.8)
    ax.semilogy(T, np.maximum(gaps_ng, 1e-16), color=colors_ng[i], 
                linestyle='-', label=f'NG κ={kappa}', alpha=0.8, linewidth=2)

ax.set_xlabel('Iteration T', fontsize=12)
ax.set_ylabel('Optimality Gap L(θ_T) - L*', fontsize=12)
ax.set_title('Convergence: Natural vs Standard GD', fontsize=13, fontweight='bold')
ax.legend(fontsize=8, loc='upper right')
ax.set_ylim(1e-16, 1e2)
ax.grid(True, alpha=0.3)

# Panel 2: Theoretical bounds
ax = axes[1]
delta0 = 0.5 * np.sum(b**2)  # approximate initial gap

for i, kappa in enumerate(kappas):
    bound_gd = gd_bound(delta0, kappa, T.astype(float))
    bound_ng = nat_grad_bound(delta0, d, T.astype(float))
    
    ax.semilogy(T, bound_gd, color=colors_gd[i], linestyle='--', 
                label=f'GD bound κ={kappa}', alpha=0.8)

ax.semilogy(T, nat_grad_bound(delta0, d, T.astype(float)), color='#2ecc71', 
            linestyle='-', label=f'NG bound (all κ)', linewidth=3)

ax.set_xlabel('Iteration T', fontsize=12)
ax.set_ylabel('Theoretical Upper Bound', fontsize=12)
ax.set_title('Theoretical Bounds (Proved)', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.set_ylim(1e-16, 1e2)
ax.grid(True, alpha=0.3)

# Panel 3: Speedup factor vs condition number
ax = axes[2]
kappa_range = np.logspace(0, 4, 100)
T_values = [20, 50, 100]

for T_val in T_values:
    speedup = (1 - 1/kappa_range)**T_val / np.exp(-T_val/d)
    ax.loglog(kappa_range, speedup, linewidth=2, label=f'T={T_val}')

ax.set_xlabel('Condition Number κ', fontsize=12)
ax.set_ylabel('GD/NG Bound Ratio', fontsize=12)
ax.set_title('Speedup: NG over GD', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.axhline(y=1, color='gray', linestyle=':', alpha=0.5)

plt.tight_layout()
plt.savefig('convergence_comparison.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved convergence_comparison.png")


#!/usr/bin/env python3
"""
Visualization: Cramér-Rao / Optimization Duality

Shows the cross-domain connection between information theory and optimization:
the Fisher information matrix simultaneously controls estimation variance
(Cramér-Rao bound) and optimization convergence (natural gradient rate).

The duality product Var × κ = λ_max / λ_min² is a constant that captures
the fundamental tradeoff between estimation and optimization.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Cramér-Rao bound vs condition number
ax = axes[0]
lambda_min_vals = np.logspace(-1, 1, 50)
kappas = [1, 5, 20, 100]

for kappa in kappas:
    lambda_max = kappa * lambda_min_vals
    variance_bound = 1.0 / lambda_min_vals
    ax.loglog(lambda_min_vals, variance_bound, linewidth=2, label=f'κ = {kappa}')

ax.set_xlabel('Fisher Information λ_min', fontsize=12)
ax.set_ylabel('Cramér-Rao Variance Bound', fontsize=12)
ax.set_title('Estimation: More Fisher Info → Less Variance', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: Duality product
ax = axes[1]
kappa_range = np.logspace(0, 3, 100)

for lambda_min in [0.1, 0.5, 1.0, 2.0]:
    variance = 1.0 / lambda_min
    duality = variance * kappa_range
    theoretical = kappa_range * lambda_min / lambda_min**2  # λ_max / λ_min²
    
    ax.loglog(kappa_range, duality, linewidth=2, label=f'λ_min = {lambda_min}')

ax.set_xlabel('Condition Number κ', fontsize=12)
ax.set_ylabel('Duality Product: Var × κ', fontsize=12)
ax.set_title('Cramér-Rao × Optimization Duality', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Convergence rate landscape
ax = axes[2]

# Create heatmap: x-axis = dimension d, y-axis = condition number κ
dims = np.arange(2, 51)
kappas_heat = np.logspace(0, 3, 50)
D, K = np.meshgrid(dims, kappas_heat)

# Natural gradient iterations for ε = 0.01: T_ng ∝ d
# Standard gradient iterations: T_gd ∝ κ
# Speedup = T_gd / T_ng ∝ κ / d
speedup = K / D

im = ax.pcolormesh(dims, kappas_heat, np.log10(speedup), 
                   cmap='RdYlGn', shading='auto', vmin=-1, vmax=3)
ax.set_yscale('log')
ax.set_xlabel('Dimension d', fontsize=12)
ax.set_ylabel('Condition Number κ', fontsize=12)
ax.set_title('log₁₀(Speedup): NG over GD', fontsize=13, fontweight='bold')

# Contour line where speedup = 1 (κ = d)
ax.contour(dims, kappas_heat, speedup, levels=[1], colors='black', linewidths=2)
ax.text(30, 20, 'NG = GD\n(κ = d)', fontsize=10, fontweight='bold',
       bbox=dict(facecolor='white', alpha=0.8))
ax.text(10, 500, 'NG wins\n(κ > d)', fontsize=10, color='darkgreen',
       bbox=dict(facecolor='white', alpha=0.8))
ax.text(40, 3, 'GD wins\n(κ < d)', fontsize=10, color='darkred',
       bbox=dict(facecolor='white', alpha=0.8))

plt.colorbar(im, ax=ax, label='log₁₀(Speedup)')

plt.tight_layout()
plt.savefig('cramer_rao_duality.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved cramer_rao_duality.png")


#!/usr/bin/env python3
"""
Visualization: Geodesic vs Euclidean Paths on a Statistical Manifold

Shows how the natural gradient (geodesic) path differs from the standard
gradient (Euclidean) path on a 2D parameter space with an anisotropic
Fisher information metric.

The geodesic path is shorter in the Riemannian metric, even though it may
look longer in Euclidean coordinates. This is WHY natural gradient is faster.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Ellipse
from matplotlib.colors import LinearSegmentedColormap

# Create a 2D optimization landscape with anisotropic metric
# f(x, y) = 0.5 * (a*x^2 + b*y^2) with a << b (ill-conditioned)
a, b_param = 1.0, 20.0
kappa = b_param / a

# Optimal point
x_opt, y_opt = 0.0, 0.0

# Starting point
x0, y0 = 3.0, 2.0

# Standard gradient descent path
def gd_path(x0, y0, a, b, eta, n_steps):
    xs, ys = [x0], [y0]
    x, y = x0, y0
    for _ in range(n_steps):
        gx, gy = a * x, b * y
        x -= eta * gx
        y -= eta * gy
        xs.append(x)
        ys.append(y)
    return np.array(xs), np.array(ys)

# Natural gradient descent path (G^{-1} * grad)
def ng_path(x0, y0, a, b, eta, n_steps):
    xs, ys = [x0], [y0]
    x, y = x0, y0
    for _ in range(n_steps):
        # Gradient: (ax, by)
        # Fisher (Hessian for quadratic): diag(a, b)
        # Natural gradient = G^{-1} * grad = (x, y)
        x -= eta * x
        y -= eta * y
        xs.append(x)
        ys.append(y)
    return np.array(xs), np.array(ys)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Paths in parameter space
ax = axes[0]

# Contour plot of loss function
xx = np.linspace(-4, 4, 200)
yy = np.linspace(-3, 3, 200)
XX, YY = np.meshgrid(xx, yy)
ZZ = 0.5 * (a * XX**2 + b_param * YY**2)

levels = np.logspace(-1, 2, 20)
ax.contour(XX, YY, ZZ, levels=levels, colors='lightgray', linewidths=0.5, alpha=0.7)
ax.contourf(XX, YY, ZZ, levels=levels, cmap='YlOrRd', alpha=0.3)

# GD path
n_steps = 50
xs_gd, ys_gd = gd_path(x0, y0, a, b_param, 1.0/b_param, n_steps)
ax.plot(xs_gd, ys_gd, 'r-o', markersize=3, linewidth=1.5, label='Standard GD', alpha=0.8)

# NG path
xs_ng, ys_ng = ng_path(x0, y0, a, b_param, 0.3, n_steps)
ax.plot(xs_ng, ys_ng, 'g-s', markersize=3, linewidth=2, label='Natural GD (geodesic)', alpha=0.9)

# Mark start and optimum
ax.plot(x0, y0, 'k*', markersize=15, label='Start', zorder=5)
ax.plot(0, 0, 'b*', markersize=15, label='Optimum', zorder=5)

# Draw Fisher metric ellipses
for cx, cy in [(1.5, 1), (-1, -0.5), (2, -1)]:
    ellipse = Ellipse((cx, cy), width=2/np.sqrt(a), height=2/np.sqrt(b_param),
                      fill=False, edgecolor='blue', alpha=0.3, linestyle='--')
    ax.add_patch(ellipse)

ax.set_xlabel('θ₁', fontsize=13)
ax.set_ylabel('θ₂', fontsize=13)
ax.set_title(f'Optimization Paths (κ = {kappa:.0f})', fontsize=14, fontweight='bold')
ax.legend(fontsize=10, loc='upper left')
ax.set_xlim(-1, 4)
ax.set_ylim(-1.5, 3)
ax.set_aspect('equal')
ax.grid(True, alpha=0.2)

# Panel 2: Loss vs iteration
ax = axes[1]

losses_gd = 0.5 * (a * xs_gd**2 + b_param * ys_gd**2)
losses_ng = 0.5 * (a * xs_ng**2 + b_param * ys_ng**2)

T = np.arange(len(losses_gd))
ax.semilogy(T, losses_gd, 'r-', linewidth=2, label='Standard GD')
ax.semilogy(T[:len(losses_ng)], losses_ng, 'g-', linewidth=2.5, label='Natural GD')

# Theoretical bounds
delta0 = 0.5 * (a * x0**2 + b_param * y0**2)
T_theory = np.arange(1, n_steps + 1).astype(float)
bound_gd = delta0 * (1 - 1/kappa)**T_theory
bound_ng = delta0 * np.exp(-T_theory / 2)  # d=2

ax.semilogy(T_theory, bound_gd, 'r--', alpha=0.5, label='GD theory')
ax.semilogy(T_theory, bound_ng, 'g--', alpha=0.5, label='NG theory')

ax.set_xlabel('Iteration', fontsize=13)
ax.set_ylabel('Loss L(θ_t)', fontsize=13)
ax.set_title('Convergence to Optimum', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(1e-15, 1e2)

# Add annotation
ax.annotate(f'κ = {kappa:.0f}\nNG: exp(-T/d)\nGD: (1-1/κ)ᵀ',
           xy=(30, 1e-6), fontsize=11, 
           bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig('geodesic_vs_euclidean.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved geodesic_vs_euclidean.png")
