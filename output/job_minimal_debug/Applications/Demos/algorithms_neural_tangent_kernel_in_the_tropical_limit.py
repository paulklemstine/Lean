"""
Tropical Kernel Dynamics — Algorithms

Implementations of the core algorithms from the tropical NTK framework:
1. Tropical NTK matrix computation
2. Polyhedral gradient descent
3. Softmin degeneration
4. Cell structure analysis
5. Lazy/feature-learning classifier
"""

import numpy as np
from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass


# ═══════════════════════════════════════════════════════════════════════
# Core Data Structures
# ═══════════════════════════════════════════════════════════════════════

@dataclass
class TropicalNetwork:
    """A tropical (min-plus) neural network: min over affine forms.

    Parameters:
        W: Weight matrix of shape (m, d) — m hidden units, d input dimension
        b: Bias vector of shape (m,)
        S: Active index set (subset of {0, ..., m-1})
    """
    W: np.ndarray
    b: np.ndarray
    S: List[int]

    def affine_score(self, i: int, x: np.ndarray) -> float:
        """Affine score of unit i on input x: W_i · x + b_i."""
        return float(self.W[i] @ x + self.b[i])

    def evaluate(self, x: np.ndarray) -> float:
        """Tropical network output: min over S of affine scores."""
        return min(self.affine_score(i, x) for i in self.S)

    def active_branch(self, x: np.ndarray) -> int:
        """Active branch: argmin over S of affine scores."""
        return min(self.S, key=lambda i: self.affine_score(i, x))

    def branch_assignment(self, samples: np.ndarray) -> List[int]:
        """Active branch for each sample."""
        return [self.active_branch(samples[n]) for n in range(len(samples))]


@dataclass
class PolyhedralLoss:
    """Max-of-affines loss: L(θ) = max_j (a_j · θ + c_j).

    Parameters:
        a: Gradient vectors of shape (M, P) — M affine pieces, P parameters
        c: Constants of shape (M,)
    """
    a: np.ndarray
    c: np.ndarray

    @property
    def num_pieces(self) -> int:
        return len(self.c)

    @property
    def param_dim(self) -> int:
        return self.a.shape[1]

    def evaluate(self, theta: np.ndarray) -> float:
        """Evaluate the polyhedral loss at theta."""
        return float(max(self.a[j] @ theta + self.c[j] for j in range(self.num_pieces)))

    def active_piece(self, theta: np.ndarray) -> int:
        """Active piece index (argmax)."""
        return int(np.argmax([self.a[j] @ theta + self.c[j] for j in range(self.num_pieces)]))

    def gradient(self, theta: np.ndarray) -> np.ndarray:
        """Gradient at theta (gradient of the active piece)."""
        j_star = self.active_piece(theta)
        return self.a[j_star].copy()


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 1: Tropical NTK Matrix Computation
# ═══════════════════════════════════════════════════════════════════════

def compute_tropical_ntk_matrix(
    net: TropicalNetwork,
    samples: np.ndarray
) -> np.ndarray:
    """Compute the tropical NTK matrix for N samples.

    The tropical NTK matrix K ∈ ℝ^{N×N} has entries:
        K_{ij} = <x_i, x_j> + 1  if active_branch(x_i) = active_branch(x_j)
        K_{ij} = 0                otherwise

    Args:
        net: Tropical network
        samples: Array of shape (N, d)

    Returns:
        K: NTK matrix of shape (N, N)

    Time complexity: O(N·m·d + N²·d) where m = |S|
    Space complexity: O(N² + N·m)
    """
    N = len(samples)
    branches = net.branch_assignment(samples)

    K = np.zeros((N, N))
    for i in range(N):
        for j in range(N):
            if branches[i] == branches[j]:
                K[i, j] = np.dot(samples[i], samples[j]) + 1.0
    return K


def verify_ntk_cellwise_constant(
    net: TropicalNetwork,
    samples: np.ndarray,
    perturbation_scale: float = 0.01,
    num_trials: int = 100
) -> Tuple[bool, float]:
    """Verify that the tropical NTK is cellwise constant by random perturbation.

    Randomly perturbs (W, b) and checks if the NTK changes only when
    the branch assignment changes.

    Returns:
        (is_consistent, max_violation): Whether all trials are consistent,
        and the maximum NTK difference when cell is preserved.
    """
    K_original = compute_tropical_ntk_matrix(net, samples)
    branches_original = net.branch_assignment(samples)
    max_violation = 0.0
    is_consistent = True

    for _ in range(num_trials):
        W_pert = net.W + np.random.randn(*net.W.shape) * perturbation_scale
        b_pert = net.b + np.random.randn(*net.b.shape) * perturbation_scale
        net_pert = TropicalNetwork(W_pert, b_pert, net.S)

        branches_pert = net_pert.branch_assignment(samples)
        K_pert = compute_tropical_ntk_matrix(net_pert, samples)

        if branches_pert == branches_original:
            diff = np.max(np.abs(K_pert - K_original))
            max_violation = max(max_violation, diff)
            if diff > 1e-10:
                is_consistent = False
        else:
            # Branches changed — kernel may differ (feature learning)
            pass

    return is_consistent, max_violation


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 2: Polyhedral Gradient Descent
# ═══════════════════════════════════════════════════════════════════════

@dataclass
class GradientDescentResult:
    """Result of polyhedral gradient descent."""
    trajectory: List[np.ndarray]
    losses: List[float]
    cell_sequence: List[int]
    wall_crossings: List[int]  # Step indices where crossings occurred
    gradients: List[np.ndarray]


def polyhedral_gradient_descent(
    loss: PolyhedralLoss,
    theta0: np.ndarray,
    eta: float,
    max_steps: int
) -> GradientDescentResult:
    """Run gradient descent on a polyhedral (max-of-affines) loss.

    On each cell, the gradient is constant and the trajectory is a
    straight line. Loss decreases by exactly η·‖g‖² per step within a cell.

    Args:
        loss: Polyhedral loss function
        theta0: Initial parameters
        eta: Step size
        max_steps: Maximum number of steps

    Returns:
        GradientDescentResult with trajectory, losses, and cell information

    Time complexity: O(max_steps · M · P) where M = num_pieces, P = param_dim
    """
    theta = theta0.copy()
    trajectory = [theta.copy()]
    losses = [loss.evaluate(theta)]
    cell_sequence = [loss.active_piece(theta)]
    wall_crossings = []
    gradients = []

    for t in range(max_steps):
        g = loss.gradient(theta)
        gradients.append(g.copy())

        # Gradient descent step
        theta = theta - eta * g
        trajectory.append(theta.copy())

        current_loss = loss.evaluate(theta)
        losses.append(current_loss)

        current_cell = loss.active_piece(theta)
        cell_sequence.append(current_cell)

        if current_cell != cell_sequence[-2]:
            wall_crossings.append(t + 1)

    return GradientDescentResult(
        trajectory=trajectory,
        losses=losses,
        cell_sequence=cell_sequence,
        wall_crossings=wall_crossings,
        gradients=gradients
    )


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 3: Softmin Degeneration
# ═══════════════════════════════════════════════════════════════════════

def softmin(tau: float, values: np.ndarray) -> float:
    """Softmin at temperature tau: smooth approximation to min.

    softmin_τ(v) = -τ · log(∑_i exp(-v_i/τ))

    Uses log-sum-exp trick for numerical stability.

    Args:
        tau: Temperature parameter (> 0)
        values: Array of values

    Returns:
        Softmin value

    As τ → 0⁺, softmin → min (Theorem: softmin_tendsto_min_of_lt)
    """
    v_min = np.min(values)
    shifted = -(values - v_min) / tau
    return float(v_min - tau * np.log(np.sum(np.exp(shifted))))


def softmin_convergence_table(
    values: np.ndarray,
    temperatures: List[float]
) -> List[Dict]:
    """Compute softmin at various temperatures and measure convergence.

    Returns a table of {tau, softmin, true_min, error, error_per_tau}.
    """
    true_min = float(np.min(values))
    results = []
    for tau in temperatures:
        sm = softmin(tau, values)
        error = abs(sm - true_min)
        results.append({
            'tau': tau,
            'softmin': sm,
            'true_min': true_min,
            'error': error,
            'error_per_tau': error / tau if tau > 0 else float('inf')
        })
    return results


def softmin_ntk_entry(tau: float, W: np.ndarray, b: np.ndarray,
                       S: List[int], x: np.ndarray, y: np.ndarray) -> float:
    """Smooth NTK entry at temperature tau.

    Uses softmin-weighted combination of gradient inner products.
    Converges to tropical NTK entry as τ → 0⁺.
    """
    scores_x = np.array([W[i] @ x + b[i] for i in S])
    scores_y = np.array([W[i] @ y + b[i] for i in S])

    # Softmax weights (from softmin)
    wx = np.exp(-scores_x / tau)
    wx /= wx.sum()
    wy = np.exp(-scores_y / tau)
    wy /= wy.sum()

    # Weighted gradient inner product
    kernel_val = 0.0
    for i_idx, i in enumerate(S):
        for j_idx, j in enumerate(S):
            if i == j:
                grad_inner = np.dot(x, y) + 1.0
            else:
                grad_inner = 0.0
            kernel_val += wx[i_idx] * wy[j_idx] * grad_inner

    return kernel_val


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 4: Cell Structure Analysis
# ═══════════════════════════════════════════════════════════════════════

def analyze_cell_structure(
    net: TropicalNetwork,
    samples: np.ndarray
) -> Dict:
    """Analyze the tropical cell structure for given samples.

    Returns:
        Dictionary with cell statistics:
        - branches: active branch for each sample
        - num_cells: number of distinct active cells
        - cell_sizes: dictionary mapping cell → count
        - cell_samples: dictionary mapping cell → list of sample indices
    """
    branches = net.branch_assignment(samples)
    unique_cells = set(branches)
    cell_sizes = {}
    cell_samples = {}

    for cell in unique_cells:
        indices = [i for i, b in enumerate(branches) if b == cell]
        cell_sizes[cell] = len(indices)
        cell_samples[cell] = indices

    return {
        'branches': branches,
        'num_cells': len(unique_cells),
        'cell_sizes': cell_sizes,
        'cell_samples': cell_samples
    }


def classify_training_regime(
    net: TropicalNetwork,
    samples: np.ndarray,
    trajectory_params: List[Tuple[np.ndarray, np.ndarray]]
) -> Dict:
    """Classify a training trajectory as lazy or feature-learning.

    Args:
        net: Initial tropical network
        samples: Training samples
        trajectory_params: List of (W, b) at each step

    Returns:
        Dictionary with:
        - regime: 'lazy' or 'feature_learning'
        - num_wall_crossings: number of cell changes
        - crossing_steps: indices where crossings occur
        - kernel_changes: max kernel difference at each step
    """
    initial_branches = TropicalNetwork(
        trajectory_params[0][0], trajectory_params[0][1], net.S
    ).branch_assignment(samples)

    K_initial = compute_tropical_ntk_matrix(
        TropicalNetwork(trajectory_params[0][0], trajectory_params[0][1], net.S),
        samples
    )

    crossing_steps = []
    kernel_changes = []
    prev_branches = initial_branches

    for t, (W_t, b_t) in enumerate(trajectory_params[1:], 1):
        net_t = TropicalNetwork(W_t, b_t, net.S)
        branches_t = net_t.branch_assignment(samples)
        K_t = compute_tropical_ntk_matrix(net_t, samples)

        if branches_t != prev_branches:
            crossing_steps.append(t)

        kernel_changes.append(float(np.max(np.abs(K_t - K_initial))))
        prev_branches = branches_t

    return {
        'regime': 'lazy' if len(crossing_steps) == 0 else 'feature_learning',
        'num_wall_crossings': len(crossing_steps),
        'crossing_steps': crossing_steps,
        'kernel_changes': kernel_changes
    }


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 5: Robustness Certificate
# ═══════════════════════════════════════════════════════════════════════

def compute_robustness_radius(
    net: TropicalNetwork,
    x: np.ndarray
) -> float:
    """Compute the robustness radius for input x.

    The robustness radius is the distance to the nearest tropical wall
    (cell boundary). Within this radius, the network's prediction is
    guaranteed constant.

    For a tropical net min_i(W_i · x + b_i) with active branch i₀,
    the robustness radius is:
        r = min_{j ≠ i₀} (score_j(x) - score_i₀(x)) / ‖W_j - W_i₀‖

    Returns:
        Robustness radius (positive real number)
    """
    i0 = net.active_branch(x)
    score_i0 = net.affine_score(i0, x)

    min_radius = float('inf')
    for j in net.S:
        if j == i0:
            continue
        score_j = net.affine_score(j, x)
        gap = score_j - score_i0  # Positive since i0 is argmin

        # Direction to wall: normalized difference of gradients
        dW = net.W[j] - net.W[i0]
        norm_dW = np.linalg.norm(dW)

        if norm_dW > 1e-12:
            radius = gap / norm_dW
            min_radius = min(min_radius, radius)

    return min_radius


if __name__ == "__main__":
    # Example usage
    np.random.seed(42)

    # Create a tropical network
    net = TropicalNetwork(
        W=np.random.randn(5, 3),
        b=np.random.randn(5),
        S=list(range(5))
    )

    # Generate samples
    samples = np.random.randn(10, 3)

    # Compute NTK
    K = compute_tropical_ntk_matrix(net, samples)
    print("Tropical NTK Matrix:")
    print(K)

    # Verify cellwise constancy
    is_const, max_viol = verify_ntk_cellwise_constant(net, samples)
    print(f"\nCellwise constant: {is_const}, max violation: {max_viol:.2e}")

    # Cell structure
    cells = analyze_cell_structure(net, samples)
    print(f"\nCell structure: {cells['num_cells']} active cells")
    print(f"Cell sizes: {cells['cell_sizes']}")

    # Robustness radii
    for i in range(min(3, len(samples))):
        r = compute_robustness_radius(net, samples[i])
        print(f"Robustness radius for sample {i}: {r:.4f}")

    # Polyhedral gradient descent
    loss = PolyhedralLoss(
        a=np.array([[2.0, 1.0], [-1.0, 2.0], [0.5, -1.5]]),
        c=np.array([0.0, 1.0, 3.0])
    )
    result = polyhedral_gradient_descent(loss, np.array([2.0, 2.0]), 0.1, 20)
    print(f"\nPolyhedral GD: {len(result.wall_crossings)} wall crossings")
    print(f"Final loss: {result.losses[-1]:.4f}")
