#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Natural Gradient Theory

Demonstrates practical applications of the formally verified convergence theory:

1. Variational Inference: Natural gradient for mean-field approximation
2. Topic Modeling: Optimizing multinomial distributions
3. Neural Network Training: Natural gradient for softmax output layers
4. Statistical Estimation: Maximum likelihood with Fisher geometry
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Optional


# ═══════════════════════════════════════════════════════════════
# Application 1: Variational Inference
# ═══════════════════════════════════════════════════════════════

class VariationalInference:
    """Natural gradient variational inference for multinomial models.
    
    Given observed counts from a categorical distribution, find the 
    variational approximation that minimizes KL divergence to the posterior.
    
    This exploits the exponential family structure: the posterior of a
    multinomial with Dirichlet prior is again in an exponential family,
    and natural gradient descent finds it efficiently.
    """
    
    def __init__(self, counts: np.ndarray, prior_alpha: float = 1.0):
        """
        Args:
            counts: Observed category counts [n_1, ..., n_K]
            prior_alpha: Dirichlet prior concentration parameter
        """
        self.counts = counts.astype(float)
        self.K = len(counts)
        self.prior_alpha = prior_alpha
        self.total = counts.sum()
        
        # Posterior mode (MAP estimate)
        post_alpha = counts + prior_alpha
        self.theta_star = np.log(post_alpha[:self.K-1] / post_alpha[-1])
    
    def log_partition(self, theta: np.ndarray) -> float:
        m = max(np.max(theta), 0.0)
        return m + np.log(np.sum(np.exp(theta - m)) + np.exp(-m))
    
    def expectation_params(self, theta: np.ndarray) -> np.ndarray:
        log_unnorm = np.concatenate([theta, [0.0]])
        log_unnorm -= log_unnorm.max()
        p = np.exp(log_unnorm)
        p /= p.sum()
        return p[:self.K-1]
    
    def fisher(self, theta: np.ndarray) -> np.ndarray:
        eta = self.expectation_params(theta)
        return np.diag(eta) - np.outer(eta, eta)
    
    def neg_log_posterior(self, theta: np.ndarray) -> float:
        """Negative log posterior (up to constant)."""
        p = np.concatenate([self.expectation_params(theta),
                           [1 - self.expectation_params(theta).sum()]])
        p = np.maximum(p, 1e-15)
        return -(self.counts @ np.log(p) + (self.prior_alpha - 1) * np.sum(np.log(p)))
    
    def grad_neg_log_posterior(self, theta: np.ndarray) -> np.ndarray:
        """Gradient of negative log posterior in natural coordinates."""
        eta = self.expectation_params(theta)
        p = np.concatenate([eta, [1 - eta.sum()]])
        p = np.maximum(p, 1e-15)
        
        # Gradient contribution from likelihood
        grad = np.zeros(self.K - 1)
        for i in range(self.K - 1):
            grad[i] = -(self.counts[i] / p[i] - self.counts[-1] / p[-1]) * eta[i] * (1 - eta[i])
            for j in range(self.K - 1):
                if j != i:
                    grad[i] += (self.counts[j] / p[j]) * eta[i] * eta[j]
        
        # Simplified: use the fact that for exp families, score is T - eta
        F = self.fisher(theta)
        expected_T = eta
        observed_freq = self.counts[:self.K-1] / self.total
        return F @ (expected_T - observed_freq) * self.total
    
    def fit_natural_gradient(self, T: int = 200) -> dict:
        """Fit using natural gradient descent with harmonic steps."""
        theta = np.zeros(self.K - 1)
        thetas = [theta.copy()]
        losses = [self.neg_log_posterior(theta)]
        
        for t in range(T):
            alpha = 1.0 / (t + 1)
            F = self.fisher(theta)
            g = self.grad_neg_log_posterior(theta)
            
            try:
                nat_grad = np.linalg.solve(F, g)
            except np.linalg.LinAlgError:
                nat_grad = g
            
            theta = theta - alpha * nat_grad
            thetas.append(theta.copy())
            losses.append(self.neg_log_posterior(theta))
        
        return {
            'thetas': thetas,
            'losses': losses,
            'final_probs': np.concatenate([self.expectation_params(theta),
                                           [1 - self.expectation_params(theta).sum()]]),
            'posterior_mode_probs': np.concatenate([
                self.expectation_params(self.theta_star),
                [1 - self.expectation_params(self.theta_star).sum()]])
        }


# ═══════════════════════════════════════════════════════════════
# Application 2: Multinomial Topic Optimization  
# ═══════════════════════════════════════════════════════════════

class TopicOptimizer:
    """Optimize topic-word distributions using natural gradient.
    
    Given a bag-of-words representation and target word frequencies,
    find the multinomial distribution that best matches while
    satisfying information-geometric smoothness constraints.
    """
    
    def __init__(self, vocab_size: int = 10):
        self.V = vocab_size
        self.dim = vocab_size - 1
    
    def softmax(self, theta: np.ndarray) -> np.ndarray:
        log_unnorm = np.concatenate([theta, [0.0]])
        log_unnorm -= log_unnorm.max()
        p = np.exp(log_unnorm)
        return p / p.sum()
    
    def kl_loss(self, theta: np.ndarray, target: np.ndarray) -> float:
        """KL(target || p_theta)."""
        p = self.softmax(theta)
        p = np.maximum(p, 1e-15)
        return np.sum(target * np.log(target / p))
    
    def fit(self, target: np.ndarray, T: int = 300) -> dict:
        """Fit using natural gradient with harmonic steps."""
        theta = np.zeros(self.dim)
        losses = [self.kl_loss(theta, target)]
        
        for t in range(T):
            alpha = 1.0 / (t + 1)
            p = self.softmax(theta)
            eta = p[:self.dim]
            F = np.diag(eta) - np.outer(eta, eta)
            
            # KL gradient in theta
            g_theta = eta - target[:self.dim]
            
            try:
                nat_grad = np.linalg.solve(F, g_theta)
            except np.linalg.LinAlgError:
                nat_grad = g_theta
            
            theta = theta - alpha * nat_grad
            losses.append(self.kl_loss(theta, target))
        
        return {'losses': losses, 'final_dist': self.softmax(theta)}


# ═══════════════════════════════════════════════════════════════
# Application 3: Fisher-Efficient Statistical Estimation
# ═══════════════════════════════════════════════════════════════

class FisherEfficientMLE:
    """Maximum likelihood estimation using natural gradient scoring.
    
    For exponential families, natural gradient MLE converges faster
    than standard gradient MLE because it adapts to the Fisher geometry.
    The Cramér-Rao bound ensures this is optimal.
    """
    
    def __init__(self, K: int = 4):
        self.K = K
        self.dim = K - 1
    
    def generate_data(self, theta_true: np.ndarray, n: int, seed: int = 0) -> np.ndarray:
        """Generate n samples from multinomial(theta_true)."""
        rng = np.random.RandomState(seed)
        log_unnorm = np.concatenate([theta_true, [0.0]])
        log_unnorm -= log_unnorm.max()
        p = np.exp(log_unnorm)
        p /= p.sum()
        return rng.choice(self.K, size=n, p=p)
    
    def neg_log_likelihood(self, theta: np.ndarray, data: np.ndarray) -> float:
        log_unnorm = np.concatenate([theta, [0.0]])
        log_unnorm -= log_unnorm.max()
        p = np.exp(log_unnorm)
        p /= p.sum()
        p = np.maximum(p, 1e-15)
        counts = np.bincount(data, minlength=self.K).astype(float)
        return -np.sum(counts * np.log(p))
    
    def fit_comparison(self, theta_true: np.ndarray, n: int = 1000, T: int = 200) -> dict:
        """Compare Euclidean GD vs Natural GD for MLE."""
        data = self.generate_data(theta_true, n)
        counts = np.bincount(data, minlength=self.K).astype(float)
        
        def loss(theta):
            return self.neg_log_likelihood(theta, data)
        
        # Euclidean GD
        theta_euc = np.zeros(self.dim)
        losses_euc = [loss(theta_euc)]
        for t in range(T):
            lr = 0.01
            log_unnorm = np.concatenate([theta_euc, [0.0]])
            log_unnorm -= log_unnorm.max()
            p = np.exp(log_unnorm)
            p /= p.sum()
            eta = p[:self.dim]
            grad = n * (eta - counts[:self.dim] / n)
            theta_euc = theta_euc - lr * grad
            losses_euc.append(loss(theta_euc))
        
        # Natural GD
        theta_ngd = np.zeros(self.dim)
        losses_ngd = [loss(theta_ngd)]
        for t in range(T):
            alpha = 1.0 / (t + 1)
            log_unnorm = np.concatenate([theta_ngd, [0.0]])
            log_unnorm -= log_unnorm.max()
            p = np.exp(log_unnorm)
            p /= p.sum()
            eta = p[:self.dim]
            F = np.diag(eta) - np.outer(eta, eta)
            grad = n * (eta - counts[:self.dim] / n)
            try:
                nat_grad = np.linalg.solve(F, grad)
            except np.linalg.LinAlgError:
                nat_grad = grad
            theta_ngd = theta_ngd - alpha * nat_grad
            losses_ngd.append(loss(theta_ngd))
        
        return {'losses_euc': losses_euc, 'losses_ngd': losses_ngd}


# ═══════════════════════════════════════════════════════════════
# Main: Run all applications
# ═══════════════════════════════════════════════════════════════

def main():
    print("=" * 70)
    print("Applications of Natural Gradient Convergence Theory")
    print("=" * 70)
    
    # ── Application 1: Variational Inference ──
    print("\n[App 1] Variational Inference for Multinomial-Dirichlet")
    counts = np.array([45, 30, 25])
    vi = VariationalInference(counts, prior_alpha=1.0)
    result = vi.fit_natural_gradient(T=200)
    print(f"  Observed counts: {counts}")
    print(f"  Final probs:     {result['final_probs']}")
    print(f"  Posterior mode:   {result['posterior_mode_probs']}")
    print(f"  Final loss:       {result['losses'][-1]:.4f}")
    
    # ── Application 2: Topic Distribution ──
    print("\n[App 2] Topic-Word Distribution Optimization")
    target = np.array([0.3, 0.2, 0.15, 0.1, 0.08, 0.07, 0.05, 0.03, 0.01, 0.01])
    topic_opt = TopicOptimizer(vocab_size=10)
    result = topic_opt.fit(target, T=300)
    print(f"  Target:   {target}")
    print(f"  Learned:  {np.round(result['final_dist'], 4)}")
    print(f"  KL loss:  {result['losses'][-1]:.6f}")
    
    # ── Application 3: MLE Comparison ──
    print("\n[App 3] Fisher-Efficient MLE (K=4 categories, n=1000)")
    mle = FisherEfficientMLE(K=4)
    theta_true = np.array([0.5, -0.3, 0.2])
    result = mle.fit_comparison(theta_true, n=1000, T=200)
    print(f"  Euclidean GD final loss: {result['losses_euc'][-1]:.4f}")
    print(f"  Natural GD final loss:   {result['losses_ngd'][-1]:.4f}")
    improvement = result['losses_euc'][-1] / max(result['losses_ngd'][-1], 1e-10)
    print(f"  Ratio (Euc/Nat):         {improvement:.2f}x")
    
    # ── Plot ──
    fig, axes = plt.subplots(1, 3, figsize=(16, 4.5))
    
    ax = axes[0]
    ax.semilogy(result['losses_euc'], label='Euclidean GD', alpha=0.8)
    ax.semilogy(result['losses_ngd'], label='Natural GD', alpha=0.8)
    ax.set_xlabel('Iteration')
    ax.set_ylabel('Negative Log-Likelihood')
    ax.set_title('App 3: MLE Convergence')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    ax = axes[1]
    vi_result = vi.fit_natural_gradient(T=200)
    ax.plot(vi_result['losses'])
    ax.set_xlabel('Iteration')
    ax.set_ylabel('Neg. Log Posterior')
    ax.set_title('App 1: Variational Inference')
    ax.grid(True, alpha=0.3)
    
    ax = axes[2]
    topic_result = topic_opt.fit(target, T=300)
    ax.semilogy(topic_result['losses'])
    ax.set_xlabel('Iteration')
    ax.set_ylabel('KL Divergence')
    ax.set_title('App 2: Topic Optimization')
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('applications_results.png', dpi=150, bbox_inches='tight')
    print(f"\n  Saved: applications_results.png")
    
    print("\n" + "=" * 70)
    print("All applications complete.")
    print("=" * 70)


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
demo.py — Natural Gradient Convergence on Dually Flat Manifolds

Demonstrates convergence properties of natural gradient descent on
exponential families (trinomial models). Compares:
  1. Euclidean gradient descent
  2. Natural gradient descent (harmonic steps)
  3. Accelerated dual natural gradient descent

Produces plots of loss decay and Bregman/KL divergence trajectories,
and estimates empirical convergence exponents.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Tuple, List

# ─────────────────────────────────────────────────────────────
# Trinomial exponential family utilities
# ─────────────────────────────────────────────────────────────

def softmax(theta: np.ndarray) -> np.ndarray:
    """Compute probabilities for a trinomial family with natural params theta (2D).
    p = [exp(theta_1), exp(theta_2), 1] / Z where Z = exp(theta_1)+exp(theta_2)+1.
    """
    log_unnorm = np.array([theta[0], theta[1], 0.0])
    log_unnorm -= log_unnorm.max()
    unnorm = np.exp(log_unnorm)
    return unnorm / unnorm.sum()

def log_partition(theta: np.ndarray) -> float:
    """Log-partition function psi(theta) = log(exp(theta_1) + exp(theta_2) + 1)."""
    m = max(theta[0], theta[1], 0.0)
    return m + np.log(np.exp(theta[0] - m) + np.exp(theta[1] - m) + np.exp(-m))

def grad_log_partition(theta: np.ndarray) -> np.ndarray:
    """Gradient of psi = expectation parameters eta = E[T]."""
    p = softmax(theta)
    return p[:2]  # eta_i = p_i for trinomial

def fisher_matrix(theta: np.ndarray) -> np.ndarray:
    """Fisher information matrix = Hessian of log-partition = Cov(T)."""
    p = softmax(theta)
    eta = p[:2]
    F = np.diag(eta) - np.outer(eta, eta)
    return F

def bregman_div(theta_star: np.ndarray, theta: np.ndarray) -> float:
    """Bregman divergence D_psi(theta_star, theta)."""
    psi_star = log_partition(theta_star)
    psi = log_partition(theta)
    grad_psi = grad_log_partition(theta)
    return psi_star - psi - grad_psi @ (theta_star - theta)

def kl_divergence(theta_star: np.ndarray, theta: np.ndarray) -> float:
    """KL divergence KL(p_star || p) = D_psi(theta_star, theta) for exp families."""
    return bregman_div(theta_star, theta)

# ─────────────────────────────────────────────────────────────
# Loss functions (convex in expectation coordinates)
# ─────────────────────────────────────────────────────────────

def quadratic_loss_eta(eta: np.ndarray, eta_star: np.ndarray) -> float:
    """Quadratic loss in expectation coords: L_eta(eta) = ||eta - eta_star||^2."""
    return 0.5 * np.sum((eta - eta_star) ** 2)

def grad_quadratic_loss_eta(eta: np.ndarray, eta_star: np.ndarray) -> np.ndarray:
    """Gradient of quadratic loss in eta coords."""
    return eta - eta_star

def loss_theta(theta: np.ndarray, eta_star: np.ndarray) -> float:
    """Loss in natural coordinates: L(theta) = L_eta(eta(theta))."""
    eta = grad_log_partition(theta)
    return quadratic_loss_eta(eta, eta_star)

def grad_loss_theta(theta: np.ndarray, eta_star: np.ndarray) -> np.ndarray:
    """Gradient of loss in theta coordinates: nabla_theta L = I(theta) * nabla_eta L_eta."""
    eta = grad_log_partition(theta)
    F = fisher_matrix(theta)
    grad_eta = grad_quadratic_loss_eta(eta, eta_star)
    return F @ grad_eta

# ─────────────────────────────────────────────────────────────
# Optimization methods
# ─────────────────────────────────────────────────────────────

def euclidean_gd(theta0: np.ndarray, eta_star: np.ndarray,
                 T: int, lr: float = 0.1) -> List[np.ndarray]:
    """Standard gradient descent in natural coordinates."""
    thetas = [theta0.copy()]
    theta = theta0.copy()
    for t in range(T):
        g = grad_loss_theta(theta, eta_star)
        theta = theta - lr * g
        thetas.append(theta.copy())
    return thetas

def natural_gd_harmonic(theta0: np.ndarray, eta_star: np.ndarray,
                        T: int) -> List[np.ndarray]:
    """Natural gradient descent with harmonic step sizes alpha_t = 1/(t+1)."""
    thetas = [theta0.copy()]
    theta = theta0.copy()
    for t in range(T):
        alpha = 1.0 / (t + 1)
        F = fisher_matrix(theta)
        g = grad_loss_theta(theta, eta_star)
        try:
            nat_grad = np.linalg.solve(F, g)
        except np.linalg.LinAlgError:
            nat_grad = np.linalg.lstsq(F, g, rcond=None)[0]
        theta = theta - alpha * nat_grad
        thetas.append(theta.copy())
    return thetas

def accelerated_dual_ngd(theta0: np.ndarray, eta_star: np.ndarray,
                         T: int) -> Tuple[List[np.ndarray], List[np.ndarray]]:
    """Accelerated dual natural gradient (Nesterov in eta-coordinates).
    
    eta_{t+1} = y_t - alpha_t * grad_eta L(y_t)
    y_{t+1} = eta_{t+1} + beta_t * (eta_{t+1} - eta_t)
    
    Returns both eta and theta sequences.
    """
    eta = grad_log_partition(theta0)
    etas = [eta.copy()]
    thetas = [theta0.copy()]
    y = eta.copy()
    eta_prev = eta.copy()
    
    for t in range(T):
        alpha = 2.0 / (t + 2)
        beta = t / (t + 3.0)
        
        # Gradient step in dual coordinates
        grad_eta = grad_quadratic_loss_eta(y, eta_star)
        eta_new = y - alpha * grad_eta
        
        # Ensure eta stays in valid range (simplex interior)
        eta_new = np.clip(eta_new, 1e-10, 1 - 1e-10)
        if eta_new.sum() >= 1 - 1e-10:
            eta_new *= (1 - 1e-10) / eta_new.sum()
        
        # Momentum
        y = eta_new + beta * (eta_new - eta_prev)
        y = np.clip(y, 1e-10, 1 - 1e-10)
        if y.sum() >= 1 - 1e-10:
            y *= (1 - 1e-10) / y.sum()
        
        eta_prev = eta_new.copy()
        etas.append(eta_new.copy())
        
        # Reconstruct theta (inverse of eta map, using Newton's method)
        theta_approx = np.log(eta_new / (1 - eta_new.sum()))
        thetas.append(theta_approx.copy())
    
    return thetas, etas

# ─────────────────────────────────────────────────────────────
# Experiments
# ─────────────────────────────────────────────────────────────

def run_single_experiment(seed: int = 42, T: int = 500):
    """Run a single comparison experiment."""
    rng = np.random.RandomState(seed)
    
    # Random target
    theta_star = rng.randn(2) * 0.5
    eta_star = grad_log_partition(theta_star)
    
    # Starting point
    theta0 = rng.randn(2) * 1.0
    
    L_star = loss_theta(theta_star, eta_star)
    
    # Run methods
    thetas_euc = euclidean_gd(theta0, eta_star, T, lr=0.5)
    thetas_ngd = natural_gd_harmonic(theta0, eta_star, T)
    thetas_acc, etas_acc = accelerated_dual_ngd(theta0, eta_star, T)
    
    # Compute losses
    losses_euc = [loss_theta(th, eta_star) - L_star for th in thetas_euc]
    losses_ngd = [loss_theta(th, eta_star) - L_star for th in thetas_ngd]
    losses_acc = [loss_theta(th, eta_star) - L_star for th in thetas_acc]
    
    # Compute Bregman divergences
    breg_euc = [bregman_div(theta_star, th) for th in thetas_euc]
    breg_ngd = [bregman_div(theta_star, th) for th in thetas_ngd]
    breg_acc = [bregman_div(theta_star, th) for th in thetas_acc]
    
    return {
        'losses_euc': losses_euc, 'losses_ngd': losses_ngd, 'losses_acc': losses_acc,
        'breg_euc': breg_euc, 'breg_ngd': breg_ngd, 'breg_acc': breg_acc,
    }

def estimate_convergence_exponent(losses: List[float], start: int = 10) -> float:
    """Estimate convergence exponent from log-log regression.
    Fits log(loss) ~ -gamma * log(t) + const.
    """
    losses_arr = np.array(losses[start:])
    losses_arr = np.maximum(losses_arr, 1e-15)
    ts = np.arange(start, start + len(losses_arr), dtype=float)
    
    mask = losses_arr > 1e-14
    if mask.sum() < 5:
        return float('inf')
    
    log_t = np.log(ts[mask])
    log_l = np.log(losses_arr[mask])
    
    # Linear regression
    A = np.vstack([log_t, np.ones_like(log_t)]).T
    slope, _ = np.linalg.lstsq(A, log_l, rcond=None)[0]
    return -slope

def run_monte_carlo(n_trials: int = 100, T: int = 300):
    """Run Monte Carlo experiment over random trinomial models."""
    exponents = {'euc': [], 'ngd': [], 'acc': []}
    
    for seed in range(n_trials):
        try:
            result = run_single_experiment(seed=seed, T=T)
            exponents['euc'].append(estimate_convergence_exponent(result['losses_euc']))
            exponents['ngd'].append(estimate_convergence_exponent(result['losses_ngd']))
            exponents['acc'].append(estimate_convergence_exponent(result['losses_acc']))
        except Exception:
            continue
    
    return exponents

def main():
    print("=" * 70)
    print("Natural Gradient Convergence on Dually Flat Manifolds")
    print("Demonstration: Trinomial Exponential Family")
    print("=" * 70)
    
    # ── Single experiment visualization ──
    print("\n[1] Running single experiment (T=500)...")
    result = run_single_experiment(seed=42, T=500)
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Loss decay
    ax = axes[0]
    T = len(result['losses_euc'])
    ts = np.arange(T)
    
    ax.semilogy(ts, np.maximum(result['losses_euc'], 1e-16), label='Euclidean GD', alpha=0.8)
    ax.semilogy(ts, np.maximum(result['losses_ngd'], 1e-16), label='Natural GD (harmonic)', alpha=0.8)
    ax.semilogy(ts, np.maximum(result['losses_acc'], 1e-16), label='Accel. Dual NGD', alpha=0.8)
    
    # Reference lines
    ref_t = np.arange(10, T)
    ax.semilogy(ref_t, 5.0 / ref_t, 'k--', alpha=0.3, label='O(1/t)')
    ax.semilogy(ref_t, 20.0 / ref_t**2, 'k:', alpha=0.3, label='O(1/t²)')
    
    ax.set_xlabel('Iteration t')
    ax.set_ylabel('Excess loss L(θ_t) - L(θ*)')
    ax.set_title('Loss Convergence Comparison')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_ylim(bottom=1e-10)
    
    # Bregman divergence decay
    ax = axes[1]
    ax.semilogy(ts, np.maximum(result['breg_euc'], 1e-16), label='Euclidean GD', alpha=0.8)
    ax.semilogy(ts, np.maximum(result['breg_ngd'], 1e-16), label='Natural GD (harmonic)', alpha=0.8)
    ax.semilogy(ts, np.maximum(result['breg_acc'], 1e-16), label='Accel. Dual NGD', alpha=0.8)
    
    ax.set_xlabel('Iteration t')
    ax.set_ylabel('Bregman divergence D_ψ(θ*, θ_t)')
    ax.set_title('Bregman Lyapunov Decay')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_ylim(bottom=1e-10)
    
    plt.tight_layout()
    plt.savefig('convergence_comparison.png', dpi=150, bbox_inches='tight')
    print("  Saved: convergence_comparison.png")
    
    # ── Convergence exponent estimation ──
    print("\n[2] Estimating convergence exponents (single run)...")
    for name, losses in [('Euclidean GD', result['losses_euc']),
                          ('Natural GD', result['losses_ngd']),
                          ('Accel. Dual NGD', result['losses_acc'])]:
        gamma = estimate_convergence_exponent(losses)
        print(f"  {name:20s}: γ ≈ {gamma:.3f}  (loss ~ t^{{-γ}})")
    
    # ── Monte Carlo study ──
    print("\n[3] Monte Carlo study: 100 random trinomial models (T=300)...")
    exponents = run_monte_carlo(n_trials=100, T=300)
    
    print("\n  Convergence exponent statistics (γ such that loss ~ t^{-γ}):")
    print(f"  {'Method':20s} {'Mean γ':>10s} {'Std γ':>10s} {'Median γ':>10s}")
    print("  " + "-" * 55)
    for name, key in [('Euclidean GD', 'euc'), ('Natural GD', 'ngd'), ('Accel. Dual NGD', 'acc')]:
        vals = [v for v in exponents[key] if np.isfinite(v) and v > 0]
        if vals:
            print(f"  {name:20s} {np.mean(vals):10.3f} {np.std(vals):10.3f} {np.median(vals):10.3f}")
    
    # Histogram
    fig, ax = plt.subplots(figsize=(8, 5))
    for name, key, color in [('Euclidean GD', 'euc', 'C0'),
                               ('Natural GD', 'ngd', 'C1'),
                               ('Accel. Dual NGD', 'acc', 'C2')]:
        vals = [v for v in exponents[key] if np.isfinite(v) and 0 < v < 5]
        if vals:
            ax.hist(vals, bins=20, alpha=0.5, label=name, color=color)
    
    ax.axvline(x=1.0, color='gray', linestyle='--', alpha=0.5, label='γ=1 (O(1/t))')
    ax.axvline(x=2.0, color='gray', linestyle=':', alpha=0.5, label='γ=2 (O(1/t²))')
    ax.set_xlabel('Convergence exponent γ')
    ax.set_ylabel('Count')
    ax.set_title('Distribution of Convergence Exponents\n(100 random trinomial models)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('exponent_distribution.png', dpi=150, bbox_inches='tight')
    print("\n  Saved: exponent_distribution.png")
    
    # ── Verify formal theorem predictions ──
    print("\n[4] Verifying formal theorem predictions...")
    print("  Theorem: t * e(t) ≤ B + A * H(t)  for harmonic step NGD")
    
    losses_ngd = result['losses_ngd']
    B = losses_ngd[0]
    harmonic_sum = 0.0
    A_est = max(losses_ngd[1], 1e-10)  # rough estimate of A
    
    violations = 0
    for t in range(1, len(losses_ngd)):
        harmonic_sum += 1.0 / t
        lhs = t * losses_ngd[t]
        rhs = B + A_est * harmonic_sum
        if lhs > rhs * 1.01:  # 1% tolerance for numerical error
            violations += 1
    
    print(f"  B = {B:.6f}, A_est = {A_est:.6f}")
    print(f"  Violations: {violations}/{len(losses_ngd)-1}")
    if violations == 0:
        print("  ✓ Bound t·e(t) ≤ B + A·H(t) holds for all t ≥ 1")
    
    # ── Bregman dissipation check ──
    print("\n  Theorem: D(t+1) ≤ D(t) for small enough steps (free energy dissipation)")
    breg_ngd = result['breg_ngd']
    monotone_from = 0
    for t in range(len(breg_ngd) - 1):
        if breg_ngd[t + 1] > breg_ngd[t] + 1e-10:
            monotone_from = t + 1
    print(f"  Bregman divergence monotonically decreasing from t={monotone_from}")
    
    print("\n" + "=" * 70)
    print("Demo complete. See convergence_comparison.png and exponent_distribution.png")
    print("=" * 70)

if __name__ == '__main__':
    main()
