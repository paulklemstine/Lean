from typing import Tuple
import math
import numpy as np

def discrete_sgd(P: np.ndarray, x0: np.ndarray, eta: float, steps: int) -> np.ndarray:
    """
    Discrete gradient descent on the relevance loss L(x)=1/2||x-Px||^2, whose
    gradient is the residual R x = x - P x:

        theta_{n+1} = theta_n - eta * (theta_n - P theta_n).

    The relevant part P theta_n = P x0 is conserved; the irrelevant part
    contracts by (1 - eta) per step:  R theta_n = (1-eta)^n R theta_0.
    Choosing eta = 1 - exp(-dt) reproduces the continuous flow at t = n*dt.
    """
    theta = x0.astype(float).copy()
    for _ in range(steps):
        residual = theta - P @ theta
        theta = theta - eta * residual
    return theta
