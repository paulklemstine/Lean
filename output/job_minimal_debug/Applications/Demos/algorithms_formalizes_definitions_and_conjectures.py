"""
Tropical Proof Theory — Algorithms
===================================

Implementations of the core tropical proof-theoretic operators,
with applications to robust neural routing and quantitative logic.
"""

import numpy as np
from typing import List, Tuple, Optional


# ──────────────────────────────────────────────────────────────
# Algorithm 1: Tropical Aggregation (Max-Plus Convolution)
# ──────────────────────────────────────────────────────────────

def tropical_agg(w: np.ndarray, x: np.ndarray) -> float:
    """
    Tropical proof aggregation: T_w(x) = max_i (w_i + x_i).
    
    This is the fundamental operator of tropical proof theory.
    It computes the "quantitative join" of weighted evidence.
    
    Time complexity: O(n)
    Space complexity: O(1)
    
    Parameters
    ----------
    w : array of shape (n,)
        Weights (proof structure coefficients).
    x : array of shape (n,)
        Input scores (evidence strengths).
    
    Returns
    -------
    float
        The tropical aggregate: max_i (w_i + x_i).
    
    Examples
    --------
    >>> tropical_agg(np.array([1, 2, 0]), np.array([3, 1, 4]))
    4.0
    """
    return float(np.max(w + x))


def tropical_agg_with_witness(w: np.ndarray, x: np.ndarray) -> Tuple[float, int]:
    """
    Tropical aggregation with witness: returns the maximizing index.
    
    The witness is the "selected proof" — the argument that achieves
    the maximum score. In attention terms, this is the attended token.
    
    Time complexity: O(n)
    Space complexity: O(1)
    
    Returns
    -------
    (value, index) : (float, int)
    """
    combined = w + x
    idx = int(np.argmax(combined))
    return float(combined[idx]), idx


# ──────────────────────────────────────────────────────────────
# Algorithm 2: Tropical Lipschitz Bound Verification
# ──────────────────────────────────────────────────────────────

def verify_lipschitz_bound(
    w: np.ndarray, x: np.ndarray, y: np.ndarray
) -> Tuple[float, float, bool]:
    """
    Verify the 1-Lipschitz bound for tropical aggregation.
    
    Computes |T_w(x) - T_w(y)| and max_i |x_i - y_i|,
    then checks that the former is ≤ the latter.
    
    This implements the certified bound from
    tropicalAgg_lipschitz_of_pointwise.
    
    Time complexity: O(n)
    Space complexity: O(n)
    
    Returns
    -------
    (lhs, rhs, holds) : (float, float, bool)
        lhs = |T_w(x) - T_w(y)|
        rhs = max_i |x_i - y_i|
        holds = (lhs ≤ rhs)
    """
    lhs = abs(tropical_agg(w, x) - tropical_agg(w, y))
    rhs = float(np.max(np.abs(x - y)))
    return lhs, rhs, lhs <= rhs + 1e-12


# ──────────────────────────────────────────────────────────────
# Algorithm 3: Tropical Hard Attention
# ──────────────────────────────────────────────────────────────

def tropical_hard_attention(
    scores: np.ndarray, values: np.ndarray
) -> Tuple[float, int]:
    """
    Hard attention via tropical selection.
    
    Selects the value at the position that maximizes score + value.
    This is the tropical proof selector: it picks the "best proof"
    considering both relevance (score) and quality (value).
    
    Pseudocode:
        1. Compute combined[i] = scores[i] + values[i] for all i
        2. Find i* = argmax_i combined[i]
        3. Return (combined[i*], i*)
    
    Time complexity: O(n)
    Space complexity: O(n)
    
    The 2-Lipschitz bound (tropicalSelect_lipschitz) guarantees
    that this selection is robust: perturbing scores and values
    by ε each changes the output by at most 2ε.
    
    Parameters
    ----------
    scores : array of shape (n,)
        Attention scores (query-key similarities).
    values : array of shape (n,)
        Token values.
    
    Returns
    -------
    (selected_value, selected_index)
    """
    combined = scores + values
    idx = int(np.argmax(combined))
    return float(combined[idx]), idx


# ──────────────────────────────────────────────────────────────
# Algorithm 4: Tropical ReLU Network Layer
# ──────────────────────────────────────────────────────────────

def tropical_relu_layer(
    W: np.ndarray, x: np.ndarray, b: np.ndarray
) -> np.ndarray:
    """
    A tropical ReLU layer: multiple neurons with tropical aggregation + ReLU.
    
    For each neuron j:
        output[j] = max(max_i(W[j,i] + x[i]) + b[j], 0)
    
    This implements a layer of tropicalReluAgg operators.
    By tropicalReluAgg_lipschitz_of_pointwise, each neuron is 1-Lipschitz.
    By tropicalAgg_comp_lipschitz, the full network is 1-Lipschitz.
    
    Pseudocode:
        1. For each output neuron j = 1..m:
           a. Compute s_j = max_i (W[j,i] + x[i])
           b. Apply ReLU: output[j] = max(s_j + b[j], 0)
        2. Return output vector
    
    Time complexity: O(m * n)  where m = output dim, n = input dim
    Space complexity: O(m)
    
    Parameters
    ----------
    W : array of shape (m, n)
        Weight matrix.
    x : array of shape (n,)
        Input vector.
    b : array of shape (m,)
        Bias vector.
    
    Returns
    -------
    output : array of shape (m,)
    """
    m = W.shape[0]
    output = np.zeros(m)
    for j in range(m):
        agg = tropical_agg(W[j], x)
        output[j] = max(agg + b[j], 0.0)
    return output


# ──────────────────────────────────────────────────────────────
# Algorithm 5: Tropical Residuated Inference
# ──────────────────────────────────────────────────────────────

def tropical_residuated_inference(
    evidence: List[Tuple[float, float]],
    threshold: float
) -> Tuple[bool, Optional[int], float]:
    """
    Tropical residuated inference engine.
    
    Given a list of (assumption_strength, implication_capacity) pairs,
    determines whether any inference chain reaches the threshold.
    
    Uses tropical residuation: a + b ≤ c ⟺ b ≤ c - a.
    
    Pseudocode:
        1. For each (a_i, b_i) pair:
           a. Compute combined strength: s_i = a_i + b_i
           b. If s_i ≥ threshold, inference succeeds via chain i
        2. Return (success, witness_index, max_strength)
    
    Time complexity: O(n)
    Space complexity: O(1)
    
    Parameters
    ----------
    evidence : list of (assumption_strength, implication_capacity) pairs
    threshold : required conclusion strength
    
    Returns
    -------
    (success, witness, max_strength) : (bool, Optional[int], float)
    """
    max_strength = float('-inf')
    best_idx = None
    
    for i, (a, b) in enumerate(evidence):
        strength = a + b
        if strength > max_strength:
            max_strength = strength
            best_idx = i
    
    success = max_strength >= threshold
    return success, best_idx if success else None, max_strength


# ──────────────────────────────────────────────────────────────
# Algorithm 6: Multi-Layer Tropical Network
# ──────────────────────────────────────────────────────────────

class TropicalNetwork:
    """
    A multi-layer tropical neural network.
    
    Each layer computes: output[j] = max_i(W[j,i] + input[i])
    Optional ReLU activation: output[j] = max(output[j] + b[j], 0)
    
    By the composition theorem (tropicalAgg_comp_lipschitz),
    the entire network is 1-Lipschitz in the sup norm,
    regardless of depth.
    
    This is the certified property: arbitrarily deep tropical
    proof circuits never amplify perturbations.
    """
    
    def __init__(self):
        self.layers: List[Tuple[np.ndarray, Optional[np.ndarray]]] = []
    
    def add_layer(self, W: np.ndarray, b: Optional[np.ndarray] = None):
        """Add a tropical layer. If b is provided, applies ReLU."""
        self.layers.append((W, b))
    
    def forward(self, x: np.ndarray) -> np.ndarray:
        """Forward pass through the tropical network."""
        current = x
        for W, b in self.layers:
            m = W.shape[0]
            output = np.zeros(m)
            for j in range(m):
                output[j] = tropical_agg(W[j], current)
                if b is not None:
                    output[j] = max(output[j] + b[j], 0.0)
            current = output
        return current
    
    def lipschitz_constant(self) -> float:
        """The theoretical Lipschitz constant: always 1.0 for tropical networks."""
        return 1.0
    
    def verify_lipschitz(self, x: np.ndarray, y: np.ndarray) -> Tuple[float, float]:
        """Verify the Lipschitz bound on a concrete pair."""
        fx = self.forward(x)
        fy = self.forward(y)
        output_dist = float(np.max(np.abs(fx - fy)))
        input_dist = float(np.max(np.abs(x - y)))
        return output_dist, input_dist


if __name__ == "__main__":
    print("Testing algorithms...")
    
    # Test tropical aggregation
    w = np.array([1.0, 2.0, 0.0])
    x = np.array([3.0, 1.0, 4.0])
    val, idx = tropical_agg_with_witness(w, x)
    print(f"tropical_agg_with_witness({w}, {x}) = ({val}, index={idx})")
    assert val == 4.0 and idx == 0
    
    # Test Lipschitz verification
    y = np.array([3.1, 0.9, 4.2])
    lhs, rhs, holds = verify_lipschitz_bound(w, x, y)
    print(f"Lipschitz: |{lhs:.4f}| ≤ {rhs:.4f} ? {holds}")
    assert holds
    
    # Test tropical network
    net = TropicalNetwork()
    net.add_layer(np.random.randn(4, 3))
    net.add_layer(np.random.randn(2, 4))
    net.add_layer(np.random.randn(1, 2))
    
    x = np.random.randn(3)
    y = x + np.random.randn(3) * 0.1
    out_dist, in_dist = net.verify_lipschitz(x, y)
    print(f"Network Lipschitz: output_dist={out_dist:.6f}, input_dist={in_dist:.6f}, "
          f"ratio={out_dist/in_dist:.6f}")
    assert out_dist <= in_dist + 1e-10
    
    print("All algorithm tests passed ✓")
