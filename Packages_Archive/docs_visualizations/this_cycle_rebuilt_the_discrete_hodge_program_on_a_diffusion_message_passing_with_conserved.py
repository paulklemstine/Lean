from __future__ import annotations
import numpy as np

def diffusion_message_passing(delta: np.ndarray, x0: np.ndarray,
                              a: float, depth: int) -> list[np.ndarray]:
    """Run depth rounds of the explicit-Euler diffusion step S = I - a*Delta.

    Returns the trajectory [x0, S x0, S^2 x0, ..., S^depth x0].  For an
    admissible step 0 < a < 2/lambda_max the non-harmonic part contracts
    geometrically while the harmonic projection P(S^k x0) stays equal to P x0.
    """
    dim = delta.shape[0]
    step = np.eye(dim) - a * delta            # S = I - a*Delta
    trajectory = [x0.copy()]
    current = x0.copy()
    for _ in range(depth):
        current = step @ current               # one message-passing round
        trajectory.append(current.copy())
    return trajectory
