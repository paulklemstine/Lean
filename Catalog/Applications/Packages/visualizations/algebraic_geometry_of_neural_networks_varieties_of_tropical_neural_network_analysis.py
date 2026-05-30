#!/usr/bin/env python3
"""
Algorithms for Tropical Analysis of Neural Network Decision Boundaries

Implements:
1. Tropical polynomial evaluation and root finding
2. Linear region enumeration for ReLU networks
3. Decision boundary extraction
4. Signed tropical rational decomposition
5. VC dimension estimation

All algorithms include docstrings, type hints, and complexity analysis.
"""

import numpy as np
from typing import List, Tuple, Optional, Set
from dataclasses import dataclass


@dataclass
class AffineFunc:
    """An affine function f(x) = slope * x + intercept."""
    slope: float
    intercept: float

    def eval(self, x: float) -> float:
        return self.slope * x + self.intercept

    def breakpoint(self) -> Optional[float]:
        """Return the ReLU breakpoint (-intercept/slope), or None if slope=0."""
        if abs(self.slope) < 1e-15:
            return None
        return -self.intercept / self.slope


@dataclass
class SingleLayerNet:
    """
    A single-layer ReLU network: f(x) = Σ wᵢ · relu(aᵢx + bᵢ) + bias.

    Attributes:
        neurons: List of affine functions for hidden neurons
        weights: Output layer weights
        bias: Output bias
    """
    neurons: List[AffineFunc]
    weights: List[float]
    bias: float

    @property
    def width(self) -> int:
        return len(self.neurons)

    def eval(self, x: float) -> float:
        """Evaluate the network at x. Time: O(w)."""
        result = self.bias
        for neuron, weight in zip(self.neurons, self.weights):
            result += weight * max(neuron.eval(x), 0.0)
        return result

    def eval_batch(self, xs: np.ndarray) -> np.ndarray:
        """Evaluate on array of inputs. Time: O(w * n)."""
        result = np.full_like(xs, self.bias)
        for neuron, weight in zip(self.neurons, self.weights):
            result += weight * np.maximum(neuron.slope * xs + neuron.intercept, 0.0)
        return result

    def breakpoints(self) -> List[float]:
        """
        Compute all breakpoints of the network.

        Time: O(w log w) (dominated by sorting)
        Space: O(w)

        Returns sorted list of unique breakpoints.
        """
        bps: Set[float] = set()
        for neuron in self.neurons:
            bp = neuron.breakpoint()
            if bp is not None:
                bps.add(bp)
        return sorted(bps)

    def linear_regions(self) -> List[Tuple[float, float, float, float]]:
        """
        Enumerate all linear regions of the network.

        Time: O(w log w)
        Space: O(w)

        Returns list of (x_start, x_end, slope, intercept) tuples defining
        each linear piece, sorted by x_start.
        """
        bps = self.breakpoints()
        if not bps:
            # Constant or single linear piece
            y0 = self.eval(0.0)
            y1 = self.eval(1.0)
            return [(-np.inf, np.inf, y1 - y0, y0)]

        regions = []
        # Before first breakpoint
        x_test = bps[0] - 1.0
        x_test2 = bps[0] - 2.0
        y1 = self.eval(x_test)
        y2 = self.eval(x_test2)
        slope = y1 - y2  # Δy/Δx with Δx=1
        intercept = y1 - slope * x_test
        regions.append((-np.inf, bps[0], slope, intercept))

        # Between breakpoints
        for i in range(len(bps) - 1):
            x_mid = (bps[i] + bps[i + 1]) / 2.0
            x_mid2 = x_mid + 0.001
            y1 = self.eval(x_mid)
            y2 = self.eval(x_mid2)
            slope = (y2 - y1) / 0.001
            intercept = y1 - slope * x_mid
            regions.append((bps[i], bps[i + 1], slope, intercept))

        # After last breakpoint
        x_test = bps[-1] + 1.0
        x_test2 = bps[-1] + 2.0
        y1 = self.eval(x_test)
        y2 = self.eval(x_test2)
        slope = y2 - y1
        intercept = y1 - slope * x_test
        regions.append((bps[-1], np.inf, slope, intercept))

        return regions

    def decision_boundary(self) -> List[float]:
        """
        Find all zeros of the network output (decision boundary points).

        Time: O(w log w)
        Space: O(w)

        Returns sorted list of x values where f(x) = 0.
        """
        regions = self.linear_regions()
        zeros = []
        for x_start, x_end, slope, intercept in regions:
            if abs(slope) < 1e-15:
                if abs(intercept) < 1e-10:
                    # Entire region is zero — degenerate case
                    continue
                continue
            x_zero = -intercept / slope
            # Check if zero is within the region
            lo = x_start if x_start != -np.inf else -1e15
            hi = x_end if x_end != np.inf else 1e15
            if lo - 1e-10 <= x_zero <= hi + 1e-10:
                zeros.append(x_zero)
        return sorted(zeros)


def tropical_polynomial_eval(coeffs: List[float], x: float) -> float:
    """
    Evaluate a tropical polynomial: max_i (a_i + i*x).

    Time: O(d) where d = len(coeffs) - 1 is the degree.

    Args:
        coeffs: Tropical coefficients [a_0, a_1, ..., a_d]
        x: Point to evaluate at

    Returns:
        max over i of (coeffs[i] + i * x)
    """
    return max(c + i * x for i, c in enumerate(coeffs))


def tropical_polynomial_roots(coeffs: List[float]) -> List[float]:
    """
    Find the roots (bend points) of a tropical polynomial.

    A root occurs where two monomials achieve the maximum simultaneously,
    i.e., where a_i + i*x = a_j + j*x for the two largest monomials.

    Time: O(d^2) naive, O(d log d) with convex hull
    Space: O(d)

    Returns sorted list of tropical roots.
    """
    d = len(coeffs) - 1
    roots = set()
    for i in range(d + 1):
        for j in range(i + 1, d + 1):
            # Solve a_i + i*x = a_j + j*x => x = (a_i - a_j) / (j - i)
            x = (coeffs[i] - coeffs[j]) / (j - i)
            # Check if this is actually a bend point (these two monomials dominate)
            val = coeffs[i] + i * x
            is_max = all(coeffs[k] + k * x <= val + 1e-10 for k in range(d + 1))
            if is_max:
                roots.add(round(x, 10))
    return sorted(roots)


@dataclass
class SignedTropicalRational:
    """
    Signed tropical rational representation: f = p⁺ - p⁻.

    A ReLU network output decomposes as the difference of two tropical
    polynomials (max-plus expressions). This captures both the positive
    and negative parts of the piecewise linear function.
    """
    pos_coeffs: List[List[float]]  # Terms in the positive tropical poly
    neg_coeffs: List[List[float]]  # Terms in the negative tropical poly

    @property
    def total_complexity(self) -> int:
        return len(self.pos_coeffs) + len(self.neg_coeffs)

    def eval(self, x: float) -> float:
        pos = max((c + s * x for c, s in self.pos_coeffs), default=0.0)
        neg = max((c + s * x for c, s in self.neg_coeffs), default=0.0)
        return pos - neg


def decompose_network(net: SingleLayerNet) -> SignedTropicalRational:
    """
    Decompose a single-layer ReLU network into signed tropical rational form.

    Each relu(ax+b) with weight w contributes:
    - If w > 0: w*(ax+b) to the positive part when ax+b > 0
    - If w < 0: |w|*(ax+b) to the negative part when ax+b > 0

    Time: O(w)
    Space: O(w)
    """
    pos_terms = [[net.bias, 0.0]]  # Constant term in positive part
    neg_terms = [[0.0, 0.0]]       # Zero in negative part

    for neuron, weight in zip(net.neurons, net.weights):
        if weight >= 0:
            pos_terms.append([weight * neuron.intercept, weight * neuron.slope])
        else:
            neg_terms.append([-weight * neuron.intercept, -weight * neuron.slope])

    return SignedTropicalRational(pos_terms, neg_terms)


def estimate_vc_dimension(net_factory, n_points: int = 100,
                          n_trials: int = 1000) -> int:
    """
    Estimate VC dimension of a network architecture by testing shattering.

    Time: O(n_trials * 2^n_points * w) — exponential, so n_points must be small
    Space: O(n_points + w)

    Args:
        net_factory: Callable that returns a random SingleLayerNet
        n_points: Maximum number of points to test
        n_trials: Number of random networks to try per labeling

    Returns:
        Estimated VC dimension (largest set size that can be shattered)
    """
    for d in range(1, min(n_points + 1, 15)):
        # Try to shatter d points
        points = np.linspace(-5, 5, d)
        n_labelings = 2 ** d
        can_shatter = True

        for labeling_idx in range(n_labelings):
            labels = [(labeling_idx >> i) & 1 for i in range(d)]
            found = False

            for _ in range(n_trials):
                net = net_factory()
                outputs = [1 if net.eval(x) > 0 else 0 for x in points]
                if outputs == labels:
                    found = True
                    break

            if not found:
                can_shatter = False
                break

        if not can_shatter:
            return d - 1

    return n_points


def depth_width_tradeoff_table(max_w: int = 10, max_L: int = 10) -> str:
    """
    Generate a table showing the depth-width tradeoff.

    Compares (w+1)^L (deep) vs L*w+1 (shallow) vs 2*L*w (linear bound).

    Time: O(max_w * max_L)
    """
    lines = []
    lines.append(f"{'w':>3} {'L':>3} {'(w+1)^L':>15} {'L*w+1':>10} {'Ratio':>10}")
    lines.append("-" * 50)
    for w in range(1, max_w + 1):
        for L in [1, 2, 3, 5]:
            if L <= max_L:
                deep = (w + 1) ** L
                shallow = L * w + 1
                ratio = deep / shallow
                lines.append(f"{w:3d} {L:3d} {deep:15d} {shallow:10d} {ratio:10.1f}")
    return "\n".join(lines)


# =============================================================================
# Example Usage
# =============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm Demo: Tropical Analysis of ReLU Networks")
    print("=" * 60)

    # Create a simple network
    net = SingleLayerNet(
        neurons=[AffineFunc(1.0, -1.0), AffineFunc(-2.0, 3.0), AffineFunc(0.5, 0.0)],
        weights=[1.0, -0.5, 2.0],
        bias=-1.0
    )

    print(f"\nNetwork with {net.width} neurons:")
    print(f"  Breakpoints: {net.breakpoints()}")
    print(f"  Linear regions: {len(net.linear_regions())}")
    print(f"  Bound: {net.width + 1}")
    print(f"  Decision boundary: {net.decision_boundary()}")

    # Tropical polynomial
    coeffs = [0.0, 1.0, -1.0]  # max(0, 1+x, -1+2x)
    print(f"\nTropical polynomial coeffs={coeffs}:")
    print(f"  Roots: {tropical_polynomial_roots(coeffs)}")
    for x in [-2, -1, 0, 1, 2]:
        print(f"  p({x}) = {tropical_polynomial_eval(coeffs, x):.1f}")

    # Signed tropical decomposition
    str = decompose_network(net)
    print(f"\nSigned tropical decomposition:")
    print(f"  Positive terms: {str.pos_coeffs}")
    print(f"  Negative terms: {str.neg_coeffs}")
    print(f"  Total complexity: {str.total_complexity}")

    # Depth-width tradeoff table
    print(f"\n{depth_width_tradeoff_table(5, 5)}")
