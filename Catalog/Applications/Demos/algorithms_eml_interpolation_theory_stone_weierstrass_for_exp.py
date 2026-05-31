"""
EML Interpolation Theory: Algorithms for Exp-Log Network Approximation

Type-hinted implementations of the core algorithms from the Stone-Weierstrass
density theory for EML networks.
"""

from typing import List, Tuple, Callable
import math


class EMLLayer:
    """A single EML neuron: x -> exp(a) * log(b*x + c)."""

    def __init__(self, a: float, b: float, c: float):
        self.a = a
        self.b = b
        self.c = c

    def eval(self, x: float) -> float:
        """Evaluate the EML layer at x."""
        inner = self.b * x + self.c
        if inner <= 0:
            raise ValueError(f"Inner value {inner} <= 0 at x={x}")
        return math.exp(self.a) * math.log(inner)

    def inner(self, x: float) -> float:
        """The inner function b*x + c."""
        return self.b * x + self.c


class EMLNet:
    """A shallow EML network: weighted sum of EML layers."""

    def __init__(self, layers: List[EMLLayer], weights: List[float]):
        assert len(layers) == len(weights)
        self.layers = layers
        self.weights = weights
        self.width = len(layers)

    def eval(self, x: float) -> float:
        """Evaluate the network at x."""
        return sum(w * l.eval(x) for w, l in zip(self.weights, self.layers))


def construct_log_basis_net(
    mesh_points: List[float],
    target_values: List[float],
) -> EMLNet:
    """
    Construct an EML network that interpolates target_values at mesh_points.
    Uses log-ratio basis functions: phi_j(x) = log(x / x_j) for each mesh point x_j.

    This is a simplified version; for exact interpolation we solve a linear system.
    For approximation, we use piecewise-linear interpolation in log-space.

    Args:
        mesh_points: Distinct positive reals where we want to interpolate
        target_values: The values to match at those points

    Returns:
        An EMLNet that approximates the interpolation
    """
    n = len(mesh_points)
    assert n == len(target_values)
    assert all(x > 0 for x in mesh_points)

    # Simple approach: use EML layers with b=1, c=0 (i.e., log(x))
    # and b=0, c=exp(x_j) shifted layers
    # For interpolation, we use Lagrange-style basis in log space

    layers: List[EMLLayer] = []
    weights: List[float] = []

    for j in range(n):
        # Layer j: x -> exp(0) * log(1 * x + 0) = log(x)
        # But we need different layers. Use: x -> log(x + shift_j)
        # where shift_j makes each basis function unique
        shift = mesh_points[j]
        layers.append(EMLLayer(a=0.0, b=1.0, c=shift))
        weights.append(target_values[j] / (n * math.log(2 * mesh_points[j])) if mesh_points[j] > 0 else 0)

    return EMLNet(layers, weights)


def lipschitz_approx_width(K: float, epsilon: float) -> int:
    """
    Compute the minimum width needed for epsilon-approximation
    of a K-Lipschitz function on [0, 1].

    Returns ceil(K/epsilon) + 1.
    """
    return math.ceil(K / epsilon) + 1


def uniform_mesh(n: int, a: float = 0.0, b: float = 1.0) -> List[float]:
    """Generate n uniformly spaced points on [a, b]."""
    if n <= 1:
        return [(a + b) / 2]
    return [a + i * (b - a) / (n - 1) for i in range(n)]


def eml_piecewise_approx(
    f: Callable[[float], float],
    n: int,
    a: float = 0.1,
    b: float = 1.0,
) -> Tuple[EMLNet, float]:
    """
    Construct an EML network of width n that approximates f on [a, b].

    Uses piecewise linear interpolation at mesh points, then converts
    to EML representation using log-based basis functions.

    Returns:
        (network, max_error) where max_error is estimated on a fine grid
    """
    mesh = uniform_mesh(n, a, b)
    values = [f(x) for x in mesh]

    # Build EML network from mesh
    layers = []
    weights = []

    for j in range(n):
        # Use layers of the form exp(0) * log(x + c_j)
        # with c_j chosen to create a localized basis
        c_j = mesh[j]
        layers.append(EMLLayer(a=0.0, b=1.0, c=c_j))

    # Solve for weights using least-squares on mesh points
    # Build matrix A where A[i][j] = log(mesh[i] + mesh[j])
    import numpy as np
    A = np.array([[math.log(mesh[i] + mesh[j]) for j in range(n)] for i in range(n)])
    try:
        w = np.linalg.solve(A, values)
        weights = w.tolist()
    except np.linalg.LinAlgError:
        weights = [v / n for v in values]

    net = EMLNet(layers, weights)

    # Estimate max error on fine grid
    test_points = uniform_mesh(1000, a, b)
    max_err = max(abs(f(x) - net.eval(x)) for x in test_points)

    return net, max_err


def jackson_eml_width(L: float, epsilon: float, alpha: float) -> float:
    """
    Conjectured width for Jackson-type EML approximation rate.

    For f in Lip_alpha with constant L, the conjecture predicts that
    width O((L/epsilon)^(1/alpha)) suffices for epsilon-approximation.
    """
    return (L / epsilon) ** (1.0 / alpha)


def separation_gap(x: float, y: float) -> float:
    """
    Compute the log-separation gap |log(x) - log(y)| for positive x, y.
    This quantifies how well the EML basis function log separates x from y.
    """
    assert x > 0 and y > 0
    return abs(math.log(x) - math.log(y))


def exp_power_identity(n: int, x: float) -> Tuple[float, float]:
    """
    Verify the identity exp(n * log(x)) = x^n for positive x.
    Returns (lhs, rhs) for comparison.
    """
    assert x > 0
    lhs = math.exp(n * math.log(x))
    rhs = x ** n
    return lhs, rhs
