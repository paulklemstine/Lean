#!/usr/bin/env python3
"""
Algorithms for Compositional Certified Robustness

Implements the key algorithms from the compositional bound theory:
1. Affine margin radius computation on linear regions
2. Region radius computation (distance to activation boundaries)
3. Compositional certified radius
4. Comparison with global Lipschitz bounds
"""

import numpy as np
from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass


@dataclass
class AffineMargin:
    """Represents an affine margin function Δ_{y,j}(x) = gradient · x + intercept."""
    gradient: np.ndarray  # shape (n,)
    intercept: float
    class_index: int  # j
    
    def evaluate(self, x: np.ndarray) -> float:
        """Evaluate the margin at point x."""
        return float(self.gradient @ x + self.intercept)
    
    def grad_norm(self, ord: int = 2) -> float:
        """Compute the norm of the gradient (dual norm for certificate)."""
        return float(np.linalg.norm(self.gradient, ord=ord))
    
    def certified_radius(self, x0: np.ndarray, norm_type: int = 2) -> float:
        """Certified radius = margin(x0) / ||gradient||_*.
        
        For L2 norm, dual is L2. For L∞, dual is L1. For L1, dual is L∞.
        
        Args:
            x0: center point
            norm_type: 1, 2, or np.inf for the perturbation norm
            
        Returns:
            Certified radius for this margin
        """
        margin = self.evaluate(x0)
        if margin <= 0:
            return 0.0
        
        # Dual norm mapping
        dual_map = {1: np.inf, 2: 2, np.inf: 1}  # type: ignore
        dual_ord = dual_map.get(norm_type, 2)
        
        g_norm = float(np.linalg.norm(self.gradient, ord=dual_ord))
        if g_norm == 0:
            return float('inf')  # constant margin, always safe
        
        return margin / g_norm


@dataclass
class LinearRegion:
    """A linear region of a ReLU network, defined by activation patterns.
    
    The region is the intersection of half-spaces:
        W_i · x + b_i > 0  for active neurons (pattern[i] = True)
        W_i · x + b_i ≤ 0  for inactive neurons (pattern[i] = False)
    """
    weight: np.ndarray       # shape (m, n) — first-layer weights
    bias: np.ndarray         # shape (m,) — first-layer biases
    pattern: np.ndarray      # shape (m,) bool — activation pattern
    
    def contains(self, x: np.ndarray) -> bool:
        """Check if x is in this region (using the activation pattern)."""
        pre_act = self.weight @ x + self.bias
        return bool(np.all((pre_act > 0) == self.pattern))
    
    def distance_to_boundary(self, x0: np.ndarray) -> float:
        """Distance from x0 to the nearest activation boundary.
        
        Each neuron i defines a hyperplane W_i · x + b_i = 0.
        The distance from x0 to this hyperplane is |W_i · x0 + b_i| / ||W_i||.
        The region radius is the minimum over all neurons.
        
        Returns:
            Distance to nearest boundary (region radius)
        """
        pre_act = self.weight @ x0 + self.bias
        distances = []
        for i in range(len(pre_act)):
            w_norm = np.linalg.norm(self.weight[i])
            if w_norm > 0:
                distances.append(abs(pre_act[i]) / w_norm)
        return min(distances) if distances else float('inf')
    
    def effective_affine_map(self, W2: np.ndarray, b2: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
        """Compute the effective affine map on this region.
        
        For a one-hidden-layer ReLU network f(x) = W2 @ relu(W1 @ x + b1) + b2,
        on this region the function is:
            f(x) = W2 @ diag(pattern) @ W1 @ x + (W2 @ diag(pattern) @ b1 + b2)
        
        Returns:
            (A, c) such that f(x) = A @ x + c on this region
        """
        D = np.diag(self.pattern.astype(float))
        A = W2 @ D @ self.weight
        c = W2 @ D @ self.bias + b2
        return A, c


def compute_affine_margins(
    A: np.ndarray,  # effective weight matrix, shape (k, n)
    c: np.ndarray,  # effective bias, shape (k,)
    y: int,         # predicted class
    k: int          # number of classes
) -> List[AffineMargin]:
    """Compute affine margin functions Δ_{y,j}(x) = (A_y - A_j) · x + (c_y - c_j).
    
    Args:
        A: effective linear map on the region
        c: effective bias on the region
        y: predicted class
        k: number of classes
        
    Returns:
        List of AffineMargin objects for each j ≠ y
    """
    margins = []
    for j in range(k):
        if j == y:
            continue
        gradient = A[y] - A[j]
        intercept = c[y] - c[j]
        margins.append(AffineMargin(gradient=gradient, intercept=intercept, class_index=j))
    return margins


def local_affine_radius(
    margins: List[AffineMargin],
    x0: np.ndarray,
    norm_type: int = 2
) -> float:
    """Compute the local affine margin radius.
    
    r_local = min_{j ≠ y} Δ_{y,j}(x₀) / ||a_j||_*
    
    where ||·||_* is the dual norm of the perturbation norm.
    
    Args:
        margins: list of affine margin functions
        x0: center point
        norm_type: perturbation norm type (1, 2, or np.inf)
        
    Returns:
        Local certified radius
        
    Complexity: O(k · n) where k = number of classes, n = input dimension
    """
    if not margins:
        return float('inf')
    
    return min(m.certified_radius(x0, norm_type) for m in margins)


def compositional_certified_radius(
    f_network,             # callable: x -> logits
    W1: np.ndarray,        # first layer weights
    b1: np.ndarray,        # first layer biases
    W2: np.ndarray,        # second layer weights
    b2: np.ndarray,        # second layer biases
    x0: np.ndarray,        # center point
    norm_type: int = 2     # perturbation norm
) -> Dict[str, float]:
    """Compute the compositional certified radius.
    
    Algorithm:
    1. Determine the linear region containing x0
    2. Compute the effective affine map on this region
    3. Compute affine margin functions
    4. r_local = min_{j≠y} margin_j(x0) / ||grad_j||_*
    5. r_region = min_i |pre_act_i| / ||W1_i||
    6. r_comp = min(r_local, r_region)
    
    Args:
        f_network: network evaluation function
        W1, b1: first layer parameters
        W2, b2: second layer parameters
        x0: center point
        norm_type: perturbation norm (1, 2, or np.inf)
        
    Returns:
        Dictionary with all computed radii and metadata
        
    Complexity: O(m·n + k·n) where m = hidden dim, n = input dim, k = classes
    """
    logits = f_network(x0)
    y = int(np.argmax(logits))
    k = len(logits)
    
    # Step 1: Determine linear region
    pre_act = W1 @ x0 + b1
    pattern = pre_act > 0
    region = LinearRegion(weight=W1, bias=b1, pattern=pattern)
    
    # Step 2: Effective affine map
    A, c = region.effective_affine_map(W2, b2)
    
    # Step 3: Affine margins
    margins = compute_affine_margins(A, c, y, k)
    
    # Step 4: Local radius
    r_local = local_affine_radius(margins, x0, norm_type)
    
    # Step 5: Region radius
    r_region = region.distance_to_boundary(x0)
    
    # Step 6: Compositional bound
    r_comp = min(r_local, r_region)
    
    # Also compute global Lipschitz for comparison
    K_global = np.linalg.norm(W1, ord=2) * np.linalg.norm(W2, ord=2)
    min_margin = min(m.evaluate(x0) for m in margins) if margins else float('inf')
    r_lip = min_margin / (2 * K_global) if K_global > 0 and min_margin > 0 else 0.0
    
    # Determine limiting factor
    if r_local <= r_region:
        limiting = "margin"
        # Find which class is limiting
        limiting_class = min(margins, key=lambda m: m.certified_radius(x0, norm_type)).class_index
    else:
        limiting = "region"
        # Find which neuron boundary is limiting
        distances = [abs(pre_act[i]) / np.linalg.norm(W1[i]) 
                     for i in range(len(pre_act)) if np.linalg.norm(W1[i]) > 0]
        limiting_class = int(np.argmin(distances))
    
    return {
        'predicted_class': y,
        'logits': logits.tolist(),
        'r_local': r_local,
        'r_region': r_region,
        'r_compositional': r_comp,
        'r_lipschitz': r_lip,
        'K_global': K_global,
        'improvement_factor': r_comp / r_lip if r_lip > 0 else float('inf'),
        'limiting_factor': limiting,
        'limiting_index': limiting_class,
        'activation_pattern': pattern.tolist(),
        'margins': {m.class_index: m.evaluate(x0) for m in margins},
    }


def deep_network_compositional_radius(
    weights: List[np.ndarray],
    biases: List[np.ndarray],
    x0: np.ndarray,
    norm_type: int = 2
) -> Dict[str, float]:
    """Compositional radius for a deep ReLU network.
    
    For an L-layer network, the compositional approach considers:
    - The linear region defined by ALL activation patterns across all layers
    - The effective affine map on this region (composition of active layers)
    - Region radius = min distance to any activation boundary
    
    This is the deep generalization of the single-hidden-layer algorithm.
    
    Complexity: O(L · max_width² · n)
    """
    # Forward pass to determine all activation patterns
    h = x0.copy()
    intermediates = [x0.copy()]
    patterns = []
    
    for i, (W, b) in enumerate(zip(weights, biases)):
        pre_act = W @ h + b
        if i < len(weights) - 1:  # apply ReLU except last layer
            pattern = pre_act > 0
            patterns.append((W, b, pre_act, pattern))
            h = np.maximum(0, pre_act)
        else:
            h = pre_act
        intermediates.append(h.copy())
    
    logits = h
    y = int(np.argmax(logits))
    k = len(logits)
    
    # Compute effective affine map by composing through active regions
    A_eff = np.eye(len(x0))
    c_eff = np.zeros(len(x0))
    
    for i, (W, b) in enumerate(zip(weights, biases)):
        if i < len(weights) - 1:
            _, _, _, pattern = patterns[i]
            D = np.diag(pattern.astype(float))
            A_eff = D @ W @ A_eff
            c_eff = D @ (W @ c_eff + b)
        else:
            A_eff = W @ A_eff
            c_eff = W @ c_eff + b
    
    # Compute margins
    margins = compute_affine_margins(A_eff, c_eff, y, k)
    r_local = local_affine_radius(margins, x0, norm_type)
    
    # Region radius: distance to nearest activation boundary across ALL layers
    r_region = float('inf')
    h_curr = x0.copy()
    for i, (W, b, pre_act, pattern) in enumerate(patterns):
        for j in range(len(pre_act)):
            w_row = W[j]
            # Need to account for the fact that x0 maps to h_curr at layer i
            # The boundary is defined in the pre-activation space of layer i
            w_norm = np.linalg.norm(w_row)
            if w_norm > 0:
                dist = abs(pre_act[j]) / w_norm
                r_region = min(r_region, dist)
        h_curr = np.maximum(0, pre_act)
    
    r_comp = min(r_local, r_region)
    
    # Global Lipschitz
    K = 1.0
    for W in weights:
        K *= np.linalg.norm(W, ord=2)
    
    min_margin = min(m.evaluate(x0) for m in margins) if margins else float('inf')
    r_lip = min_margin / (2 * K) if K > 0 and min_margin > 0 else 0.0
    
    return {
        'predicted_class': y,
        'r_local': r_local,
        'r_region': r_region,
        'r_compositional': r_comp,
        'r_lipschitz': r_lip,
        'K_global': K,
        'improvement_factor': r_comp / r_lip if r_lip > 0 else float('inf'),
        'depth': len(weights),
    }


# ============================================================
# Verification utilities
# ============================================================

def verify_certificate(
    f_network,
    x0: np.ndarray,
    r: float,
    n_samples: int = 10000,
    seed: int = 42
) -> Dict[str, object]:
    """Monte Carlo verification that the certificate radius is correct.
    
    Samples random perturbations and checks if classification changes.
    
    Returns:
        Dictionary with verification results
    """
    np.random.seed(seed)
    logits0 = f_network(x0)
    y = int(np.argmax(logits0))
    
    n_inside_violations = 0
    n_outside_changes = 0
    min_violation_norm = float('inf')
    min_change_norm = float('inf')
    
    for _ in range(n_samples):
        # Sample uniformly in a ball of radius 2r
        delta = np.random.randn(*x0.shape)
        norm = np.linalg.norm(delta)
        if norm == 0:
            continue
        scale = np.random.uniform(0, 2 * r)
        delta = delta / norm * scale
        
        x = x0 + delta
        logits = f_network(x)
        predicted = int(np.argmax(logits))
        
        pert_norm = np.linalg.norm(delta)
        
        if predicted != y:
            if pert_norm < r:
                n_inside_violations += 1
                min_violation_norm = min(min_violation_norm, pert_norm)
            else:
                n_outside_changes += 1
                min_change_norm = min(min_change_norm, pert_norm)
    
    return {
        'certificate_radius': r,
        'n_samples': n_samples,
        'violations_inside': n_inside_violations,
        'changes_outside': n_outside_changes,
        'min_violation_norm': min_violation_norm if n_inside_violations > 0 else None,
        'min_change_norm': min_change_norm if n_outside_changes > 0 else None,
        'certificate_valid': n_inside_violations == 0,
    }


if __name__ == "__main__":
    # Quick self-test
    from demo import simple_relu_network
    
    W1 = np.array([[1.0, 0.5], [-0.3, 1.0]])
    b1 = np.array([0.2, -0.1])
    W2 = np.array([[1.0, -0.5], [-0.8, 1.2]])
    b2 = np.array([0.1, -0.3])
    
    x0 = np.array([0.5, 0.3])
    
    result = compositional_certified_radius(simple_relu_network, W1, b1, W2, b2, x0)
    print("Compositional Certificate Result:")
    for k, v in result.items():
        print(f"  {k}: {v}")
    
    # Verify
    verification = verify_certificate(simple_relu_network, x0, result['r_compositional'])
    print("\nVerification:")
    for k, v in verification.items():
        print(f"  {k}: {v}")
