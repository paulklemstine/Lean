#!/usr/bin/env python3
"""
Algorithms for Tropical Adversarial Regularization

Implements the key algorithms from the research paper:
1. Tropical regularized empirical risk computation
2. Certified radius computation
3. Tropical gradient descent training
"""

import numpy as np
from typing import Tuple, List, Optional, Callable


def hinge_loss(z: np.ndarray) -> np.ndarray:
    """Compute hinge loss max(0, 1-z).

    Args:
        z: Array of margin values.

    Returns:
        Hinge loss values.

    Example:
        >>> hinge_loss(np.array([0.5, 1.0, 1.5, -0.5]))
        array([0.5, 0. , 0. , 1.5])
    """
    return np.maximum(0.0, 1.0 - z)


def margin_surplus(z: np.ndarray) -> np.ndarray:
    """Compute margin surplus max(0, z-1).

    The margin surplus measures how much the classification margin exceeds
    the hinge loss threshold. Points with positive surplus have zero
    empirical loss and contribute no tropical penalty unless the
    perturbation budget exceeds their surplus.

    Args:
        z: Array of margin values.

    Returns:
        Margin surplus values.
    """
    return np.maximum(0.0, z - 1.0)


def tropical_penalty(
    margins: np.ndarray,
    delta: float
) -> float:
    """Compute total tropical penalty for a dataset.

    Tropical penalty = Σ max(0, δ - marginSurplus(mᵢ))

    This is the min-plus regularizer that bridges adversarial training
    to tropical geometry. It penalizes points whose margin surplus
    is less than the perturbation budget.

    Args:
        margins: Array of classification margins.
        delta: Perturbation budget in margin units (= L * ε).

    Returns:
        Total tropical penalty.

    Time complexity: O(n) where n = len(margins).
    """
    return np.sum(np.maximum(0.0, delta - margin_surplus(margins)))


def tropical_regularized_risk(
    margins: np.ndarray,
    delta: float
) -> Tuple[float, float, float]:
    """Compute the tropical regularized risk decomposition.

    By the core algebraic identity (Theorem A):
        R_shifted = R_emp + tropical_penalty

    Args:
        margins: Array of classification margins.
        delta: Perturbation budget (= L * ε).

    Returns:
        Tuple (R_shifted, R_emp, tropical_penalty).
    """
    r_emp = np.sum(hinge_loss(margins))
    trop_pen = tropical_penalty(margins, delta)
    r_shifted = r_emp + trop_pen  # = Σ hingeLoss(mᵢ - δ) by Theorem A
    return r_shifted, r_emp, trop_pen


def certified_radii(
    margins: np.ndarray,
    lipschitz_const: float
) -> np.ndarray:
    """Compute certified robustness radii for all data points.

    By Theorem B, the certified radius at point x is:
        r(x) = max(0, margin(x)) / L

    Within this radius, the classification is provably stable.

    Args:
        margins: Array of classification margins.
        lipschitz_const: Lipschitz constant L of the score function.

    Returns:
        Array of certified radii.

    Time complexity: O(n).
    """
    assert lipschitz_const > 0, "Lipschitz constant must be positive"
    return np.maximum(0.0, margins) / lipschitz_const


def global_certified_radius(
    margins: np.ndarray,
    lipschitz_const: float
) -> float:
    """Compute the global certified radius (minimum over correctly classified points).

    Args:
        margins: Array of classification margins.
        lipschitz_const: Lipschitz constant L.

    Returns:
        Global certified radius (0 if any point is misclassified).
    """
    radii = certified_radii(margins, lipschitz_const)
    positive_radii = radii[margins > 0]
    if len(positive_radii) == 0:
        return 0.0
    return float(np.min(positive_radii))


class TropicalLinearClassifier:
    """Linear classifier trained with tropical regularization.

    Optimizes: R_emp(w) + λ * tropical_penalty(margins(w), L(w) * ε)

    where L(w) = ||w|| is the Lipschitz constant and margins(w) = y * (X @ w).

    Attributes:
        w: Weight vector.
        bias: Bias term.
        lam: Tropical regularization strength.
        epsilon: Perturbation budget.
    """

    def __init__(
        self,
        dim: int,
        lam: float = 1.0,
        epsilon: float = 0.5
    ):
        self.w = np.zeros(dim)
        self.bias = 0.0
        self.lam = lam
        self.epsilon = epsilon
        self._loss_history: List[float] = []

    def margins(self, X: np.ndarray, y: np.ndarray) -> np.ndarray:
        """Compute classification margins."""
        return y * (X @ self.w + self.bias)

    def lipschitz_const(self) -> float:
        """Lipschitz constant = ||w||."""
        return float(np.linalg.norm(self.w))

    def predict(self, X: np.ndarray) -> np.ndarray:
        """Predict class labels."""
        return np.sign(X @ self.w + self.bias)

    def compute_risk(
        self,
        X: np.ndarray,
        y: np.ndarray
    ) -> Tuple[float, float, float]:
        """Compute decomposed risk.

        Returns:
            Tuple (total_risk, empirical_risk, tropical_penalty).
        """
        m = self.margins(X, y)
        L = self.lipschitz_const()
        delta = L * self.epsilon
        return tropical_regularized_risk(m, delta)

    def fit(
        self,
        X: np.ndarray,
        y: np.ndarray,
        lr: float = 0.01,
        epochs: int = 200,
        verbose: bool = False
    ) -> 'TropicalLinearClassifier':
        """Train the classifier using tropical-regularized gradient descent.

        Args:
            X: Feature matrix (n_samples, n_features).
            y: Labels in {-1, 1}.
            lr: Learning rate.
            epochs: Number of training epochs.
            verbose: Print progress every 50 epochs.

        Returns:
            self (for chaining).

        Time complexity per epoch: O(n * d) where n = samples, d = features.
        Space complexity: O(n + d).
        """
        n = X.shape[0]
        self._loss_history = []

        for epoch in range(epochs):
            m = self.margins(X, y)
            L = self.lipschitz_const()
            delta = L * self.epsilon

            # Empirical risk gradient
            emp_active = (m < 1).astype(float)
            grad_w = -np.mean((y * emp_active)[:, None] * X, axis=0)
            grad_b = -np.mean(y * emp_active)

            # Tropical penalty gradient
            if L > 1e-10:
                surp = margin_surplus(m)
                pen_active = (delta > surp).astype(float)
                # d/dw tropical_penalty has two parts:
                # 1. From δ = L*ε: gradient through L = ||w||
                grad_w += self.lam * self.epsilon * np.mean(pen_active) * self.w / L
                # 2. From margin_surplus: only when margin > 1
                surplus_active = (m > 1).astype(float) * pen_active
                grad_w -= self.lam * np.mean((y * surplus_active)[:, None] * X, axis=0)
                grad_b -= self.lam * np.mean(y * surplus_active)

            # Update
            self.w -= lr * grad_w
            self.bias -= lr * grad_b

            # Record loss
            total, emp, pen = self.compute_risk(X, y)
            self._loss_history.append(total)

            if verbose and (epoch % 50 == 0 or epoch == epochs - 1):
                print(f"Epoch {epoch:4d}: loss={total:.4f} "
                      f"(emp={emp:.4f}, pen={pen:.4f}), "
                      f"L={self.lipschitz_const():.3f}")

        return self

    def get_certified_radii(
        self,
        X: np.ndarray,
        y: np.ndarray
    ) -> np.ndarray:
        """Get certified robustness radii for all points."""
        m = self.margins(X, y)
        L = self.lipschitz_const()
        if L < 1e-10:
            return np.zeros(len(X))
        return certified_radii(m, L)

    @property
    def loss_history(self) -> List[float]:
        return self._loss_history


def compute_tropical_moreau_envelope(
    margins: np.ndarray,
    costs: np.ndarray,
    lipschitz_const: float,
    epsilon: float
) -> np.ndarray:
    """Compute the tropical Moreau envelope of the margin function.

    (T_ε m)(x) = inf_{x'} { m(x') + L * c(x, x') }

    In practice for finite datasets, this is:
        min_j { m(x_j) + L * cost(x_i, x_j) }

    This is the min-plus convolution that connects adversarial robustness
    to tropical geometry.

    Args:
        margins: Margin values at each point.
        costs: Pairwise cost matrix (n × n).
        lipschitz_const: Lipschitz constant.
        epsilon: Perturbation budget.

    Returns:
        Enveloped margin values.
    """
    n = len(margins)
    envelope = np.zeros(n)
    for i in range(n):
        # Restrict to perturbation ball
        in_ball = costs[i] <= epsilon
        if np.any(in_ball):
            envelope[i] = np.min(margins[in_ball] + lipschitz_const * costs[i, in_ball])
        else:
            envelope[i] = margins[i]
    return envelope


if __name__ == '__main__':
    # Example usage
    np.random.seed(42)
    n, d = 100, 2

    X_pos = np.random.randn(n // 2, d) + np.array([2, 2])
    X_neg = np.random.randn(n // 2, d) + np.array([-2, -2])
    X = np.vstack([X_pos, X_neg])
    y = np.concatenate([np.ones(n // 2), -np.ones(n // 2)])

    print("Training TropicalLinearClassifier...")
    clf = TropicalLinearClassifier(dim=d, lam=0.5, epsilon=0.3)
    clf.fit(X, y, lr=0.01, epochs=300, verbose=True)

    print(f"\nFinal weights: {clf.w}")
    print(f"Lipschitz constant: {clf.lipschitz_const():.4f}")

    radii = clf.get_certified_radii(X, y)
    print(f"Min certified radius: {np.min(radii[radii > 0]):.4f}")
    print(f"Mean certified radius: {np.mean(radii[radii > 0]):.4f}")
    print(f"Accuracy: {np.mean(clf.predict(X) == y):.2%}")
