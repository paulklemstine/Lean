"""
Tropical Learning Algorithms
==============================

Implements learning in the tropical semiring via morphological gradients:

    - MorphologicalGradient: Tropical subdifferential (dilation/erosion)
    - TropicalBackprop: Backpropagation through tropical (max-plus) layers
    - TropicalSGD: Stochastic gradient descent with tropical updates
    - tropical_train: High-level training loop

Key insight: In the tropical semiring, the "gradient" of max(f_1, ..., f_k)
is the subdifferential — the set of gradients of the active piece.
Tropical backprop computes which piece is active (argmax) at each layer
and propagates the corresponding gradient.

This is equivalent to:
    1. Dynamic programming (Bellman optimality)
    2. Morphological operations (dilation = max-plus convolution)
    3. Viterbi-style decoding (finding the optimal path)
"""

import numpy as np
from typing import List, Callable, Optional, Tuple
from qtlib.networks import TropicalNetwork, TropicalLinear, TropicalReLU, TropicalLoss


class MorphologicalGradient:
    """Computes morphological (tropical) gradients.

    The morphological gradient of a tropical linear map y = max_j(W_{ij} + x_j)
    is the indicator of the active (argmax) index:

        ∂y_i/∂W_{ij} = 1 if j = argmax_k(W_{ik} + x_k), else 0
        ∂y_i/∂x_j = 1 if j = argmax_k(W_{ik} + x_k), else 0

    This is a "hard attention" gradient — only the winning path carries signal.
    """

    @staticmethod
    def compute(layer: TropicalLinear) -> dict:
        """Compute morphological gradient for a tropical linear layer.

        Returns
        -------
        dict with:
            'dW': gradient w.r.t. weights, shape (out, in)
            'dx': gradient w.r.t. input, shape (in,)
            'active_paths': list of (output_idx, input_idx) active connections
        """
        grad_info = layer.tropical_gradient()
        active_paths = []
        for i in range(layer.out_features):
            j_star = layer._last_argmax[i]
            active_paths.append((i, j_star))

        # Input gradient: which input dimensions are "active"
        dx = np.zeros(layer.in_features)
        for i, j in active_paths:
            dx[j] = max(dx[j], 1.0)

        return {
            'dW': grad_info['dW'],
            'db': grad_info.get('db'),
            'dx': dx,
            'active_paths': active_paths,
        }


class TropicalBackprop:
    """Tropical backpropagation through a network.

    Instead of computing ∂L/∂W via the chain rule with real-valued gradients,
    tropical backprop traces the "winning path" through the network:

    1. Forward pass: compute outputs and record argmax at each layer
    2. Backward pass: trace the winning path from output to input
    3. Update: modify weights along the winning path

    This is equivalent to the Viterbi algorithm in HMMs.
    """

    def __init__(self, network: TropicalNetwork, loss: TropicalLoss):
        self.network = network
        self.loss = loss

    def compute_gradients(self, x: np.ndarray, target: np.ndarray) -> List[dict]:
        """Compute tropical gradients for all layers.

        Parameters
        ----------
        x : input vector
        target : target vector

        Returns
        -------
        gradients : list of dicts, one per trainable layer
        """
        # Forward pass
        prediction = self.network.forward(x)

        # Compute loss gradient (which output should increase/decrease)
        if self.loss.loss_type == 'tropical_mse':
            error = prediction - target
            # Tropical gradient of max|error|: focus on largest error
            worst_idx = np.argmax(np.abs(error))
            output_grad = np.zeros_like(prediction)
            output_grad[worst_idx] = np.sign(error[worst_idx])
        elif self.loss.loss_type == 'tropical_hinge':
            correct = np.argmax(target)
            output_grad = np.zeros_like(prediction)
            output_grad[correct] = 1.0
            worst_other = np.argmax(prediction - target * 1e10)
            output_grad[worst_other] = -1.0
        else:
            output_grad = np.sign(prediction - target)

        # Backward pass: trace winning paths
        gradients = []
        current_grad = output_grad

        for layer in reversed(self.network.layers):
            if isinstance(layer, TropicalLinear):
                morph_grad = MorphologicalGradient.compute(layer)

                # Scale morphological gradient by output gradient
                dW = np.zeros_like(layer.W)
                for i, j in morph_grad['active_paths']:
                    if i < len(current_grad):
                        dW[i, j] = current_grad[i]

                gradients.append({
                    'dW': dW,
                    'db': morph_grad.get('db'),
                    'layer': layer,
                })

                # Propagate gradient to input
                new_grad = np.zeros(layer.in_features)
                for i, j in morph_grad['active_paths']:
                    if i < len(current_grad):
                        new_grad[j] += current_grad[i]
                current_grad = new_grad

            elif isinstance(layer, TropicalReLU):
                relu_grad = layer.tropical_gradient()
                current_grad = current_grad * relu_grad

        gradients.reverse()
        return gradients


class TropicalSGD:
    """Tropical Stochastic Gradient Descent.

    Updates weights using tropical (morphological) gradients:
        W_{ij} ← W_{ij} - lr · ∂L/∂W_{ij}

    where the gradient is computed by tropical backpropagation
    (tracing the winning path).

    Parameters
    ----------
    network : TropicalNetwork
    lr : float
        Learning rate
    momentum : float
        Momentum coefficient (0 = no momentum)
    """

    def __init__(self, network: TropicalNetwork, lr: float = 0.01,
                 momentum: float = 0.0):
        self.network = network
        self.lr = lr
        self.momentum = momentum
        self.velocities = {}

    def step(self, gradients: List[dict]):
        """Apply one optimization step.

        Parameters
        ----------
        gradients : list of gradient dicts from TropicalBackprop
        """
        for grad_info in gradients:
            layer = grad_info['layer']
            dW = grad_info['dW']

            # Initialize velocity if needed
            layer_id = id(layer)
            if layer_id not in self.velocities:
                self.velocities[layer_id] = np.zeros_like(layer.W)

            # Update with momentum
            v = self.velocities[layer_id]
            v = self.momentum * v - self.lr * dW
            self.velocities[layer_id] = v
            layer.W += v

            if grad_info.get('db') is not None and layer.b is not None:
                layer.b -= self.lr * grad_info['db']


def tropical_train(network: TropicalNetwork,
                   X_train: np.ndarray,
                   y_train: np.ndarray,
                   epochs: int = 100,
                   lr: float = 0.01,
                   loss_type: str = 'tropical_mse',
                   verbose: bool = True) -> dict:
    """High-level training loop for tropical neural networks.

    Parameters
    ----------
    network : TropicalNetwork
    X_train : array of shape (n_samples, n_features)
    y_train : array of shape (n_samples, n_outputs)
    epochs : int
    lr : float
    loss_type : str
    verbose : bool

    Returns
    -------
    history : dict with 'losses' (list of per-epoch average losses)
    """
    loss_fn = TropicalLoss(loss_type)
    backprop = TropicalBackprop(network, loss_fn)
    optimizer = TropicalSGD(network, lr=lr, momentum=0.9)

    n_samples = X_train.shape[0]
    losses = []

    for epoch in range(epochs):
        epoch_loss = 0.0
        indices = np.random.permutation(n_samples)

        for idx in indices:
            x = X_train[idx]
            y = y_train[idx]

            # Forward + backward
            pred = network.forward(x)
            loss_val = loss_fn.compute(pred, y)
            grads = backprop.compute_gradients(x, y)

            # Update
            optimizer.step(grads)
            epoch_loss += loss_val

        avg_loss = epoch_loss / n_samples
        losses.append(avg_loss)

        if verbose and (epoch % 10 == 0 or epoch == epochs - 1):
            print(f"Epoch {epoch:4d} | Loss: {avg_loss:.6f}")

    return {'losses': losses}
