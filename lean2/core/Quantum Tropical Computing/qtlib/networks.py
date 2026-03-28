"""
Tropical Neural Network Layers
================================

Implements neural network layers using tropical (max-plus) arithmetic:

    - TropicalLinear:  y_i = max_j(W_{ij} + x_j)     (tropical matrix-vector product)
    - TropicalReLU:    y_i = max(x_i, 0)               (tropical addition with zero)
    - TropicalSoftmax: y_i = exp(β·x_i) / Σ exp(β·x_j) (Maslov measurement)
    - TropicalNetwork: Sequential composition of layers

Key insight: A deep ReLU network computes a tropical rational function.
Each TropicalLinear layer is a max-plus matrix multiplication, and
TropicalReLU is tropical addition with the tropical multiplicative identity.
"""

import numpy as np
from typing import List, Optional, Tuple
from qtlib.semiring import trop_matvec, TROP_NEG_INF, maslov_add


class TropicalLinear:
    """Tropical linear layer: y_i = max_j(W_{ij} + x_j)

    This is the tropical matrix-vector product, equivalent to a
    one-step Bellman update in dynamic programming.

    Parameters
    ----------
    in_features : int
    out_features : int
    bias : bool
        If True, add a tropical bias: y_i = max(max_j(W_{ij} + x_j), b_i)
    """

    def __init__(self, in_features: int, out_features: int, bias: bool = True):
        self.in_features = in_features
        self.out_features = out_features
        self.has_bias = bias

        # Initialize weights (tropical: uniform random, not Gaussian)
        self.W = np.random.uniform(-1, 1, (out_features, in_features))
        self.b = np.zeros(out_features) if bias else None

        # Store last input/output for backpropagation
        self._last_input = None
        self._last_output = None
        self._last_argmax = None

    def forward(self, x: np.ndarray) -> np.ndarray:
        """Forward pass: tropical matrix-vector product.

        Parameters
        ----------
        x : array of shape (in_features,) or (batch, in_features)

        Returns
        -------
        y : array of shape (out_features,) or (batch, out_features)
        """
        if x.ndim == 1:
            return self._forward_single(x)
        return np.array([self._forward_single(xi) for xi in x])

    def _forward_single(self, x: np.ndarray) -> np.ndarray:
        self._last_input = x.copy()
        # y_i = max_j(W_{ij} + x_j)
        scores = self.W + x[None, :]  # (out, in) broadcast
        self._last_argmax = np.argmax(scores, axis=1)
        y = np.max(scores, axis=1)
        if self.has_bias:
            y = np.maximum(y, self.b)
        self._last_output = y
        return y

    def tropical_gradient(self) -> dict:
        """Compute the tropical subdifferential (morphological gradient).

        In tropical backpropagation, the "gradient" of max_j(W_{ij} + x_j)
        with respect to W_{ij*} (where j* = argmax) is 1, and 0 otherwise.
        This is the tropical analogue of the chain rule.

        Returns
        -------
        dict with 'dW' and 'db' (sparse gradients)
        """
        if self._last_input is None:
            raise RuntimeError("Call forward() first")

        dW = np.zeros_like(self.W)
        for i in range(self.out_features):
            j_star = self._last_argmax[i]
            dW[i, j_star] = 1.0

        db = None
        if self.has_bias:
            db = np.zeros_like(self.b)
            # Bias is active when b_i > max_j(W_{ij} + x_j)
            for i in range(self.out_features):
                if self.b[i] > self._last_output[i]:
                    db[i] = 1.0

        return {'dW': dW, 'db': db}


class TropicalReLU:
    """Tropical ReLU: y = max(x, 0) = x ⊕ 0

    This is literally tropical addition with the tropical multiplicative
    identity (0). In a tropical neural network, this layer is the
    "nonlinearity" — but it's actually a LINEAR operation in tropical algebra!
    """

    def forward(self, x: np.ndarray) -> np.ndarray:
        self._last_input = x.copy()
        return np.maximum(x, 0.0)

    def tropical_gradient(self) -> np.ndarray:
        """Gradient: 1 where x > 0, 0 where x < 0 (subdifferential at 0)."""
        return (self._last_input > 0).astype(float)


class TropicalSoftmax:
    """Maslov measurement: softmax with temperature β.

    p_i = exp(β · x_i) / Σ_j exp(β · x_j)

    β → 0:  uniform distribution (quantum superposition)
    β = 1:  standard softmax (ML regime)
    β → ∞:  one-hot on maximum (tropical WTA measurement)
    """

    def __init__(self, beta: float = 1.0):
        self.beta = beta

    def forward(self, x: np.ndarray) -> np.ndarray:
        s = self.beta * x
        s = s - np.max(s)  # numerical stability
        exp_s = np.exp(s)
        return exp_s / np.sum(exp_s)

    def set_beta(self, beta: float):
        self.beta = beta


class TropicalLoss:
    """Tropical loss functions for training.

    Supported losses:
        'tropical_mse': max_i |y_i - t_i|  (tropical L∞ loss)
        'tropical_cross_entropy': -t^T · y  (tropical inner product loss)
        'tropical_hinge': max(0, margin - (y_correct - y_other))
    """

    def __init__(self, loss_type: str = 'tropical_mse'):
        self.loss_type = loss_type

    def compute(self, prediction: np.ndarray, target: np.ndarray) -> float:
        if self.loss_type == 'tropical_mse':
            return float(np.max(np.abs(prediction - target)))
        elif self.loss_type == 'tropical_cross_entropy':
            return -float(np.max(prediction + target))  # tropical inner product
        elif self.loss_type == 'tropical_hinge':
            correct = np.argmax(target)
            margins = prediction[correct] - prediction
            margins[correct] = float('inf')
            return float(np.max(np.maximum(0, 1.0 - margins)))
        else:
            raise ValueError(f"Unknown loss type: {self.loss_type}")


class TropicalNetwork:
    """Sequential tropical neural network.

    A stack of TropicalLinear and TropicalReLU layers.

    Example
    -------
    >>> net = TropicalNetwork([
    ...     TropicalLinear(4, 8),
    ...     TropicalReLU(),
    ...     TropicalLinear(8, 3),
    ... ])
    >>> output = net.forward(np.array([1.0, 2.0, 3.0, 4.0]))
    """

    def __init__(self, layers: List = None):
        self.layers = layers or []

    def add(self, layer) -> 'TropicalNetwork':
        self.layers.append(layer)
        return self

    def forward(self, x: np.ndarray) -> np.ndarray:
        for layer in self.layers:
            x = layer.forward(x)
        return x

    def parameters(self) -> List[dict]:
        """Collect all trainable parameters."""
        params = []
        for i, layer in enumerate(self.layers):
            if isinstance(layer, TropicalLinear):
                params.append({
                    'layer_idx': i,
                    'W': layer.W,
                    'b': layer.b,
                    'layer': layer,
                })
        return params

    def __repr__(self):
        lines = ["TropicalNetwork("]
        for i, layer in enumerate(self.layers):
            lines.append(f"  [{i}] {layer.__class__.__name__}")
        lines.append(")")
        return "\n".join(lines)
