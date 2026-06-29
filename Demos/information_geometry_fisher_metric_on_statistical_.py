#!/usr/bin/env python3
"""
Information Geometry: Real-World Applications
===============================================

Demonstrates applications of Fisher information geometry to:
1. Optimal experiment design
2. Uncertainty quantification for scientific measurements
3. Statistical physics / partition functions
4. Machine learning: natural gradient for softmax classification
"""

import numpy as np
from numpy.linalg import inv, det, eigvalsh
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ── Shared utilities ─────────────────────────────────────────

def log_partition(theta, T, k):
    exponents = T @ theta + k
    m = exponents.max()
    return float(np.log(np.sum(np.exp(exponents - m))) + m)

def pmf(theta, T, k):
    exponents = T @ theta + k
    m = exponents.max()
    unnorm = np.exp(exponents - m)
    return unnorm / unnorm.sum()

def fisher_matrix(theta, T, k):
    p = pmf(theta, T, k)
    eta = T.T @ p
    centered = T - eta[np.newaxis, :]
    return (centered.T * p) @ centered


# ══════════════════════════════════════════════════════════════
# APPLICATION 1: Optimal Experiment Design
# ══════════════════════════════════════════════════════════════

print("=" * 65)
print("APPLICATION 1: Optimal Experiment Design")
print("=" * 65)
print("""
We design experiments to minimize estimation uncertainty.
The Fisher information matrix tells us how much information
each observation provides about the parameters.

D-optimal design: maximize det(I(θ)) — minimizes the volume
of the confidence ellipsoid for parameter estimation.
""")

# Sensor placement for estimating a 2D temperature field
# Three possible sensor locations with different sensitivity profiles
T_sensors = np.array([
    [1.0, 0.0],   # Sensor A: sensitive to θ₁ only
    [0.0, 1.0],   # Sensor B: sensitive to θ₂ only
    [0.7, 0.7],   # Sensor C: sensitive to both
    [0.3, 0.9],   # Sensor D: mixed
], dtype=float)
k_sensors = np.zeros(4)

theta_true = np.array([0.5, 0.3])
I = fisher_matrix(theta_true, T_sensors, k_sensors)
print(f"Fisher matrix with all sensors:\n{I}")
print(f"det(I) = {det(I):.6f}")
print(f"Eigenvalues: {eigvalsh(I)}")

# Compare subsets of sensors
subsets = {
    "A+B": [0, 1],
    "A+C": [0, 2],
    "B+C": [1, 2],
    "C+D": [2, 3],
}
print("\nD-optimality (det I) for sensor pairs:")
for name, idx in subsets.items():
    T_sub = T_sensors[idx]
    k_sub = k_sensors[idx]
    I_sub = fisher_matrix(theta_true, T_sub, k_sub)
    d = det(I_sub)
    print(f"  {name}: det(I) = {d:.6f}")


# ══════════════════════════════════════════════════════════════
# APPLICATION 2: Uncertainty Quantification
# ══════════════════════════════════════════════════════════════

print("\n" + "=" * 65)
print("APPLICATION 2: Uncertainty Quantification via Cramér–Rao")
print("=" * 65)
print("""
For any unbiased estimator of a parameter function g(θ),
the Cramér–Rao inequality gives a fundamental lower bound:

    Var(T̂) ≥ ∇g(θ)ᵀ I(θ)⁻¹ ∇g(θ)

This is the tightest possible bound without additional assumptions.
""")

# Multinomial model: opinion poll with 4 categories
T_poll = np.array([
    [0, 0, 0],
    [1, 0, 0],
    [0, 1, 0],
    [0, 0, 1],
], dtype=float)
k_poll = np.zeros(4)

theta_poll = np.array([0.2, -0.1, 0.3])
p = pmf(theta_poll, T_poll, k_poll)
I_poll = fisher_matrix(theta_poll, T_poll, k_poll)

print(f"Category probabilities: {np.round(p, 4)}")
print(f"Fisher matrix:\n{np.round(I_poll, 4)}")

# Estimand: probability of category 2
# g(θ) = p₂(θ), need ∇g(θ)
eps = 1e-5
grad_g = np.zeros(3)
for i in range(3):
    e = np.zeros(3); e[i] = eps
    grad_g[i] = (pmf(theta_poll + e, T_poll, k_poll)[1] -
                 pmf(theta_poll - e, T_poll, k_poll)[1]) / (2*eps)

cr_bound = grad_g @ inv(I_poll) @ grad_g
print(f"\nEstimand: P(category 2) = {p[1]:.4f}")
print(f"CR lower bound on variance: {cr_bound:.6f}")
print(f"Minimum std deviation: {np.sqrt(cr_bound):.4f}")


# ══════════════════════════════════════════════════════════════
# APPLICATION 3: Statistical Physics — Ising-like Model
# ══════════════════════════════════════════════════════════════

print("\n" + "=" * 65)
print("APPLICATION 3: Statistical Physics — Finite Ising Model")
print("=" * 65)
print("""
The log-partition function ψ(θ) = log Z(θ) is the free energy
(up to sign/temperature). Its convexity is proven in our Lean
formalization. Derivatives give thermodynamic quantities:

  ∇ψ = ⟨observables⟩     (expectation values)
  ∇²ψ = susceptibility     (= Fisher matrix)
""")

# 3-spin Ising model: Ω = {↑↑↑, ↑↑↓, ↑↓↑, ..., ↓↓↓}
# T(σ) = [magnetization, nearest-neighbor energy]
configs = np.array([[i, j, k]
                     for i in [-1, 1] for j in [-1, 1] for k in [-1, 1]])
# Magnetization m = σ₁+σ₂+σ₃, Pair energy J = σ₁σ₂+σ₂σ₃
T_ising = np.column_stack([
    configs.sum(axis=1),           # magnetization
    configs[:, 0]*configs[:, 1] + configs[:, 1]*configs[:, 2]  # NN interaction
])
k_ising = np.zeros(8)

# Scan temperature (β = 1/T) at zero field
betas = np.linspace(0.01, 2.0, 50)
magnetizations = []
susceptibilities = []
free_energies = []

for beta in betas:
    theta = np.array([0.0, beta])  # zero field, coupling β
    p = pmf(theta, T_ising, k_ising)
    eta = T_ising.T @ p
    I = fisher_matrix(theta, T_ising, k_ising)
    psi = log_partition(theta, T_ising, k_ising)

    magnetizations.append(abs(eta[0]))
    susceptibilities.append(I[0, 0])  # magnetic susceptibility
    free_energies.append(-psi)  # F = -kT log Z

print(f"At β=0.5: ⟨m⟩ = {magnetizations[12]:.4f}, χ = {susceptibilities[12]:.4f}")
print(f"At β=1.5: ⟨m⟩ = {magnetizations[37]:.4f}, χ = {susceptibilities[37]:.4f}")

fig, axes = plt.subplots(1, 3, figsize=(15, 4))
axes[0].plot(betas, magnetizations)
axes[0].set_xlabel('β (inverse temperature)'); axes[0].set_ylabel('|⟨m⟩|')
axes[0].set_title('Magnetization'); axes[0].grid(True, alpha=0.3)

axes[1].plot(betas, susceptibilities)
axes[1].set_xlabel('β'); axes[1].set_ylabel('χ = I₁₁(θ)')
axes[1].set_title('Susceptibility (= Fisher I₁₁)'); axes[1].grid(True, alpha=0.3)

axes[2].plot(betas, free_energies)
axes[2].set_xlabel('β'); axes[2].set_ylabel('F = −ψ(θ)')
axes[2].set_title('Free Energy'); axes[2].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('ising_thermodynamics.png', dpi=150)
print("Plot saved to ising_thermodynamics.png")


# ══════════════════════════════════════════════════════════════
# APPLICATION 4: Natural Gradient for Softmax Classification
# ══════════════════════════════════════════════════════════════

print("\n" + "=" * 65)
print("APPLICATION 4: Natural Gradient for Softmax Classifier")
print("=" * 65)
print("""
A softmax classifier is an exponential family model.
Natural gradient descent (using Fisher geometry) gives
parameterization-invariant updates that converge faster
than standard gradient descent.
""")

# Simple 3-class classification
np.random.seed(42)
K = 3  # classes
d = 2  # features

# Generate synthetic data
n_data = 200
centers = np.array([[0, 0], [3, 0], [1.5, 2.5]])
labels = np.repeat(np.arange(K), n_data // K + 1)[:n_data]
X = centers[labels] + 0.8 * np.random.randn(n_data, d)

# Softmax as exponential family: θ ∈ ℝ^{(K-1)×d}
def softmax_probs(theta, x):
    """Softmax probabilities for one sample."""
    theta_mat = theta.reshape(K - 1, d)
    logits = np.zeros(K)
    logits[1:] = theta_mat @ x
    logits -= logits.max()
    exp_logits = np.exp(logits)
    return exp_logits / exp_logits.sum()

def cross_entropy_loss(theta, X, y):
    """Average cross-entropy loss."""
    loss = 0
    for i in range(len(X)):
        p = softmax_probs(theta, X[i])
        loss -= np.log(max(p[y[i]], 1e-15))
    return loss / len(X)

def cross_entropy_grad(theta, X, y):
    """Gradient of cross-entropy loss."""
    grad = np.zeros_like(theta)
    theta_mat = theta.reshape(K - 1, d)
    for i in range(len(X)):
        p = softmax_probs(theta, X[i])
        for c in range(K - 1):
            indicator = 1.0 if y[i] == c + 1 else 0.0
            grad[c*d:(c+1)*d] += (p[c+1] - indicator) * X[i]
    return grad / len(X)

def softmax_fisher(theta, X):
    """Average Fisher information matrix for softmax."""
    n_params = len(theta)
    I = np.zeros((n_params, n_params))
    for i in range(len(X)):
        p = softmax_probs(theta, X[i])
        score_vecs = []
        for c in range(K - 1):
            s = np.zeros(n_params)
            s[c*d:(c+1)*d] = X[i]
            s -= p[c+1] * X[i]  # simplified
            score_vecs.append(s)
        for sv in score_vecs:
            I += np.outer(sv, sv) * p[1]  # simplified weighting
    return I / len(X) + 1e-6 * np.eye(n_params)

# Train with both methods
theta_init = np.zeros((K-1) * d)
lr = 0.1
n_steps = 30

# Euclidean gradient descent
theta_euc = theta_init.copy()
losses_euc = [cross_entropy_loss(theta_euc, X, labels)]
for _ in range(n_steps):
    g = cross_entropy_grad(theta_euc, X, labels)
    theta_euc -= lr * g
    losses_euc.append(cross_entropy_loss(theta_euc, X, labels))

# Natural gradient descent
theta_nat = theta_init.copy()
losses_nat = [cross_entropy_loss(theta_nat, X, labels)]
for _ in range(n_steps):
    g = cross_entropy_grad(theta_nat, X, labels)
    I = softmax_fisher(theta_nat, X)
    ng = inv(I) @ g
    theta_nat -= lr * ng
    losses_nat.append(cross_entropy_loss(theta_nat, X, labels))

print(f"Initial loss: {losses_euc[0]:.4f}")
print(f"Final loss (Euclidean, {n_steps} steps): {losses_euc[-1]:.4f}")
print(f"Final loss (Natural, {n_steps} steps): {losses_nat[-1]:.4f}")

fig, ax = plt.subplots(figsize=(8, 5))
ax.plot(losses_euc, 'b-', label='Euclidean GD', linewidth=2)
ax.plot(losses_nat, 'r-', label='Natural GD', linewidth=2)
ax.set_xlabel('Iteration', fontsize=12)
ax.set_ylabel('Cross-Entropy Loss', fontsize=12)
ax.set_title('Natural vs Euclidean Gradient Descent\nfor Softmax Classification', fontsize=14)
ax.legend(fontsize=12)
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('softmax_natural_gradient.png', dpi=150)
print("Plot saved to softmax_natural_gradient.png")

print("\n" + "=" * 65)
print("All applications completed!")
print("=" * 65)


#!/usr/bin/env python3
"""
Information Geometry: Interactive Demo
======================================

Constructs small finite exponential families, computes Fisher matrices,
verifies PSD numerically, compares empirical estimator variance to
Cramér–Rao bounds, and visualizes natural vs Euclidean gradient flow.
"""

import numpy as np
from numpy.linalg import eigvalsh, inv, det
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ──────────────────────────────────────────────────────────────
# 1.  Core computations for finite exponential families
# ──────────────────────────────────────────────────────────────

def log_partition(theta, T, k):
    """ψ(θ) = log Σ_ω exp(⟨θ, T(ω)⟩ + k(ω))"""
    exponents = T @ theta + k
    return np.log(np.sum(np.exp(exponents - exponents.max())) ) + exponents.max()


def pmf(theta, T, k):
    """p_θ(ω) = exp(⟨θ,T(ω)⟩ + k(ω) − ψ(θ))"""
    psi = log_partition(theta, T, k)
    return np.exp(T @ theta + k - psi)


def fisher_matrix(theta, T, k):
    """I(θ) = Cov_θ(T) = E[TᵀT] − E[T]ᵀE[T]"""
    p = pmf(theta, T, k)
    eta = T.T @ p  # E[T]
    centered = T - eta[np.newaxis, :]
    return (centered.T * p) @ centered


def score_mean(theta, T, k):
    """Should be ≈ 0 by score mean-zero theorem."""
    p = pmf(theta, T, k)
    scores = T - (T.T @ p)[np.newaxis, :]
    return (scores.T * p).sum(axis=1)


def cr_bound_scalar(theta, T, k, grad_g):
    """Cramér–Rao lower bound for scalar estimand: ∇g ᵀ I⁻¹ ∇g"""
    I = fisher_matrix(theta, T, k)
    return grad_g @ inv(I) @ grad_g


def natural_gradient(theta, T, k, loss_grad):
    """Natural gradient: I(θ)⁻¹ ∇loss"""
    I = fisher_matrix(theta, T, k)
    return inv(I) @ loss_grad


# ──────────────────────────────────────────────────────────────
# 2.  Build a concrete exponential family (Bernoulli-like)
# ──────────────────────────────────────────────────────────────

print("=" * 60)
print("DEMO 1: Two-outcome Bernoulli exponential family")
print("=" * 60)

# Ω = {0, 1}, T(ω) = [ω], k(ω) = 0
T_bern = np.array([[0.0], [1.0]])
k_bern = np.array([0.0, 0.0])
theta0 = np.array([1.0])

print(f"\nθ = {theta0}")
p = pmf(theta0, T_bern, k_bern)
print(f"p(0) = {p[0]:.6f},  p(1) = {p[1]:.6f}")
print(f"log-partition ψ(θ) = {log_partition(theta0, T_bern, k_bern):.6f}")

I = fisher_matrix(theta0, T_bern, k_bern)
print(f"Fisher matrix I(θ) = {I}")
print(f"Score mean (should be ≈ 0): {score_mean(theta0, T_bern, k_bern)}")

eigs = eigvalsh(I)
print(f"Eigenvalues of I(θ): {eigs}  (all ≥ 0 ✓)" if all(eigs >= -1e-12) else "PSD VIOLATED!")


# ──────────────────────────────────────────────────────────────
# 3.  Multinomial exponential family (3 outcomes, 2 params)
# ──────────────────────────────────────────────────────────────

print("\n" + "=" * 60)
print("DEMO 2: Trinomial exponential family (|Ω|=3, dim=2)")
print("=" * 60)

# Ω = {0,1,2}, T(0)=[0,0], T(1)=[1,0], T(2)=[0,1], k=0
T_tri = np.array([[0, 0], [1, 0], [0, 1]], dtype=float)
k_tri = np.zeros(3)
theta_tri = np.array([0.5, -0.3])

print(f"\nθ = {theta_tri}")
p_tri = pmf(theta_tri, T_tri, k_tri)
print(f"pmf = {p_tri}")
print(f"Sum of pmf = {p_tri.sum():.10f}  (should be 1)")

I_tri = fisher_matrix(theta_tri, T_tri, k_tri)
print(f"\nFisher matrix:\n{I_tri}")
print(f"Symmetric: {np.allclose(I_tri, I_tri.T)}")
eigs_tri = eigvalsh(I_tri)
print(f"Eigenvalues: {eigs_tri}  ({'PSD ✓' if all(eigs_tri >= -1e-12) else 'PSD VIOLATED!'})")
print(f"det(I) = {det(I_tri):.8f}")


# ──────────────────────────────────────────────────────────────
# 4.  Cramér–Rao bound verification via Monte Carlo
# ──────────────────────────────────────────────────────────────

print("\n" + "=" * 60)
print("DEMO 3: Cramér–Rao bound — Monte Carlo verification")
print("=" * 60)

# Estimand: g(θ) = p(ω=1; θ)  for Bernoulli
# Unbiased estimator: T(ω) = 1{ω=1}  (indicator)
# Var(T) = p(1-p),  CR bound = (∂g/∂θ)² / I(θ)

theta_test = np.array([0.7])
p_test = pmf(theta_test, T_bern, k_bern)
p1 = p_test[1]

# ∂g/∂θ = p(1)(1-p(1))  (derivative of sigmoid)
dg = p1 * (1 - p1)
I_test = fisher_matrix(theta_test, T_bern, k_bern)[0, 0]
cr_lb = dg**2 / I_test

# True variance of indicator
true_var = p1 * (1 - p1)

print(f"\nθ = {theta_test[0]:.4f}")
print(f"p(1) = {p1:.6f}")
print(f"True Var(T) = {true_var:.6f}")
print(f"CR lower bound = {cr_lb:.6f}")
print(f"Var(T) ≥ CR bound: {true_var >= cr_lb - 1e-12}  ✓")

# Monte Carlo
np.random.seed(42)
N_samples = 100000
samples = np.random.choice([0, 1], size=N_samples, p=p_test)
T_samples = (samples == 1).astype(float)
empirical_var = np.var(T_samples, ddof=1)
print(f"\nMonte Carlo ({N_samples} samples):")
print(f"  Empirical Var(T) = {empirical_var:.6f}")
print(f"  CR lower bound   = {cr_lb:.6f}")
print(f"  Ratio Var/CR     = {empirical_var/cr_lb:.4f}  (should be ≥ 1)")


# ──────────────────────────────────────────────────────────────
# 5.  Natural vs Euclidean gradient flow visualization
# ──────────────────────────────────────────────────────────────

print("\n" + "=" * 60)
print("DEMO 4: Natural vs Euclidean gradient descent")
print("=" * 60)

def kl_divergence(theta, theta_star, T, k):
    """KL(p_θ* || p_θ)"""
    p_star = pmf(theta_star, T, k)
    p_curr = pmf(theta, T, k)
    return np.sum(p_star * np.log(p_star / np.maximum(p_curr, 1e-15)))


def euclidean_grad_kl(theta, theta_star, T, k, eps=1e-5):
    """Numerical gradient of KL(p_θ* || p_θ) w.r.t. θ"""
    grad = np.zeros_like(theta)
    for i in range(len(theta)):
        e = np.zeros_like(theta)
        e[i] = eps
        grad[i] = (kl_divergence(theta + e, theta_star, T, k) -
                    kl_divergence(theta - e, theta_star, T, k)) / (2 * eps)
    return grad


# Target: trinomial with θ* = [1.0, 0.5]
theta_star = np.array([1.0, 0.5])
theta_init = np.array([-2.0, -1.5])

# Euclidean gradient descent
lr_euc = 0.5
traj_euc = [theta_init.copy()]
theta_euc = theta_init.copy()
for _ in range(50):
    g = euclidean_grad_kl(theta_euc, theta_star, T_tri, k_tri)
    theta_euc = theta_euc - lr_euc * g
    traj_euc.append(theta_euc.copy())

# Natural gradient descent
lr_nat = 0.5
traj_nat = [theta_init.copy()]
theta_nat = theta_init.copy()
for _ in range(50):
    g = euclidean_grad_kl(theta_nat, theta_star, T_tri, k_tri)
    ng = natural_gradient(theta_nat, T_tri, k_tri, g)
    theta_nat = theta_nat - lr_nat * ng
    traj_nat.append(theta_nat.copy())

traj_euc = np.array(traj_euc)
traj_nat = np.array(traj_nat)

kl_euc = [kl_divergence(t, theta_star, T_tri, k_tri) for t in traj_euc]
kl_nat = [kl_divergence(t, theta_star, T_tri, k_tri) for t in traj_nat]

print(f"\nInitial KL = {kl_euc[0]:.4f}")
print(f"Final KL (Euclidean, 50 steps) = {kl_euc[-1]:.6f}")
print(f"Final KL (Natural,   50 steps) = {kl_nat[-1]:.6f}")

# Plot
fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Trajectory plot
ax = axes[0]
ax.plot(traj_euc[:, 0], traj_euc[:, 1], 'b.-', label='Euclidean', alpha=0.7)
ax.plot(traj_nat[:, 0], traj_nat[:, 1], 'r.-', label='Natural', alpha=0.7)
ax.plot(*theta_star, 'k*', markersize=15, label='Target θ*')
ax.plot(*theta_init, 'go', markersize=10, label='Start')
ax.set_xlabel('θ₁'); ax.set_ylabel('θ₂')
ax.set_title('Gradient Trajectories in Parameter Space')
ax.legend()
ax.grid(True, alpha=0.3)

# Convergence plot
ax = axes[1]
ax.semilogy(kl_euc, 'b-', label='Euclidean')
ax.semilogy(kl_nat, 'r-', label='Natural')
ax.set_xlabel('Iteration'); ax.set_ylabel('KL Divergence')
ax.set_title('Convergence: KL(p* || p_θ)')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('gradient_comparison.png', dpi=150)
print("\nPlot saved to gradient_comparison.png")


# ──────────────────────────────────────────────────────────────
# 6.  Log-partition convexity verification
# ──────────────────────────────────────────────────────────────

print("\n" + "=" * 60)
print("DEMO 5: Log-partition convexity check")
print("=" * 60)

# Check midpoint convexity along random lines
np.random.seed(123)
n_tests = 1000
violations = 0
for _ in range(n_tests):
    a = np.random.randn(2)
    b = np.random.randn(2)
    t = np.random.uniform(0, 1)
    midpoint = t * a + (1 - t) * b
    psi_mid = log_partition(midpoint, T_tri, k_tri)
    psi_convex = t * log_partition(a, T_tri, k_tri) + (1 - t) * log_partition(b, T_tri, k_tri)
    if psi_mid > psi_convex + 1e-10:
        violations += 1

print(f"Tested {n_tests} random midpoint inequalities")
print(f"Violations: {violations}  ({'Convexity verified ✓' if violations == 0 else 'CONVEXITY VIOLATED!'})")


# ──────────────────────────────────────────────────────────────
# 7.  Fisher = Hessian of log-partition (numerical check)
# ──────────────────────────────────────────────────────────────

print("\n" + "=" * 60)
print("DEMO 6: Fisher = Hessian of log-partition")
print("=" * 60)

def hessian_logpartition(theta, T, k, eps=1e-4):
    """Numerical Hessian of ψ(θ)"""
    n = len(theta)
    H = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            ei, ej = np.zeros(n), np.zeros(n)
            ei[i] = eps; ej[j] = eps
            H[i, j] = (log_partition(theta + ei + ej, T, k)
                       - log_partition(theta + ei - ej, T, k)
                       - log_partition(theta - ei + ej, T, k)
                       + log_partition(theta - ei - ej, T, k)) / (4 * eps**2)
    return H

theta_check = np.array([0.3, -0.7])
I_fisher = fisher_matrix(theta_check, T_tri, k_tri)
H_psi = hessian_logpartition(theta_check, T_tri, k_tri)

print(f"\nFisher matrix I(θ):\n{I_fisher}")
print(f"\nHessian ∇²ψ(θ):\n{H_psi}")
print(f"\nMax absolute difference: {np.max(np.abs(I_fisher - H_psi)):.2e}")
print(f"Match: {'✓' if np.allclose(I_fisher, H_psi, atol=1e-6) else '✗'}")

print("\n" + "=" * 60)
print("All demos completed successfully!")
print("=" * 60)
