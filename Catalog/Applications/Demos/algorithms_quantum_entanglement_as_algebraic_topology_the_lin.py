#!/usr/bin/env python3
"""
Algorithms for Quantum Entanglement and Topological Linking

Implements the core algorithms connecting quantum entanglement measures
to topological invariants via the Hopf fibration.

Algorithms:
1. Concurrence computation for arbitrary two-qubit states
2. Hopf-Entanglement Invariant (scale-invariant)
3. Hopf fibration map S^7 → S^4
4. Linking number estimation via Gauss integral
5. State classification (product vs entangled)
"""

import numpy as np
from typing import Tuple, List, Optional


class TwoQubitState:
    """A two-qubit quantum state |ψ⟩ = α|00⟩ + β|01⟩ + γ|10⟩ + δ|11⟩.

    Attributes:
        alpha, beta, gamma, delta: Complex amplitudes
    """

    def __init__(self, alpha: complex, beta: complex, gamma: complex, delta: complex):
        self.alpha = complex(alpha)
        self.beta = complex(beta)
        self.gamma = complex(gamma)
        self.delta = complex(delta)

    @classmethod
    def random_normalized(cls) -> 'TwoQubitState':
        """Generate a random normalized state (Haar-uniform on S^7)."""
        coeffs = np.random.randn(4) + 1j * np.random.randn(4)
        norm = np.sqrt(sum(abs(c)**2 for c in coeffs))
        return cls(*(c / norm for c in coeffs))

    @classmethod
    def random_product(cls) -> 'TwoQubitState':
        """Generate a random product state (a,b) ⊗ (c,d)."""
        a, b = np.random.randn(2) + 1j * np.random.randn(2)
        c, d = np.random.randn(2) + 1j * np.random.randn(2)
        return cls(a*c, a*d, b*c, b*d)

    @classmethod
    def bell_phi_plus(cls) -> 'TwoQubitState':
        """Bell state |Φ+⟩ = (|00⟩ + |11⟩)/√2."""
        s = 1 / np.sqrt(2)
        return cls(s, 0, 0, s)

    @classmethod
    def bell_phi_minus(cls) -> 'TwoQubitState':
        """Bell state |Φ-⟩ = (|00⟩ - |11⟩)/√2."""
        s = 1 / np.sqrt(2)
        return cls(s, 0, 0, -s)

    @classmethod
    def bell_psi_plus(cls) -> 'TwoQubitState':
        """Bell state |Ψ+⟩ = (|01⟩ + |10⟩)/√2."""
        s = 1 / np.sqrt(2)
        return cls(0, s, s, 0)

    @classmethod
    def bell_psi_minus(cls) -> 'TwoQubitState':
        """Bell state |Ψ-⟩ = (|01⟩ - |10⟩)/√2."""
        s = 1 / np.sqrt(2)
        return cls(0, s, -s, 0)

    def norm_sq(self) -> float:
        """Compute ‖ψ‖² = |α|² + |β|² + |γ|² + |δ|²."""
        return (abs(self.alpha)**2 + abs(self.beta)**2 +
                abs(self.gamma)**2 + abs(self.delta)**2)

    def is_normalized(self, tol: float = 1e-10) -> bool:
        """Check if the state is normalized."""
        return abs(self.norm_sq() - 1.0) < tol

    def normalize(self) -> 'TwoQubitState':
        """Return a normalized copy of this state."""
        n = np.sqrt(self.norm_sq())
        if n == 0:
            return TwoQubitState(0, 0, 0, 0)
        return TwoQubitState(self.alpha/n, self.beta/n, self.gamma/n, self.delta/n)

    def entanglement_det(self) -> complex:
        """Compute the entanglement determinant αδ - βγ.

        This is the determinant of the 2×2 coefficient matrix.
        Time complexity: O(1)
        """
        return self.alpha * self.delta - self.beta * self.gamma

    def concurrence(self) -> float:
        """Compute the concurrence C(ψ) = 2|αδ - βγ|.

        The standard entanglement measure for pure two-qubit states.
        Range: [0, 1] for normalized states (0 = product, 1 = maximally entangled).
        Time complexity: O(1)
        """
        return 2 * abs(self.entanglement_det())

    def hopf_entanglement_invariant(self) -> float:
        """Compute HEI(ψ) = 2|αδ - βγ| / ‖ψ‖².

        Scale-invariant version of concurrence.
        Equal to concurrence for normalized states.
        Time complexity: O(1)
        """
        ns = self.norm_sq()
        if ns == 0:
            return 0.0
        return 2 * abs(self.entanglement_det()) / ns

    def coefficient_matrix(self) -> np.ndarray:
        """Return the 2×2 coefficient matrix [[α, β], [γ, δ]].

        The determinant of this matrix equals the entanglement determinant.
        """
        return np.array([[self.alpha, self.beta],
                         [self.gamma, self.delta]])

    def is_product(self, tol: float = 1e-10) -> bool:
        """Check if the state is a product state (unentangled).

        A state is a product state iff its entanglement determinant is zero,
        which is equivalent to the coefficient matrix having rank ≤ 1.
        Time complexity: O(1)
        """
        return abs(self.entanglement_det()) < tol

    def classify(self) -> str:
        """Classify the entanglement level of the state.

        Returns one of: 'product', 'weakly entangled', 'moderately entangled',
        'strongly entangled', 'maximally entangled'.
        """
        c = self.hopf_entanglement_invariant()
        if c < 1e-10:
            return 'product'
        elif c < 0.25:
            return 'weakly entangled'
        elif c < 0.75:
            return 'moderately entangled'
        elif c < 1 - 1e-10:
            return 'strongly entangled'
        else:
            return 'maximally entangled'

    def tropical_bound(self) -> float:
        """Compute the tropical/AM-GM bound on entanglement.

        Returns (|α|²+|δ|²)/2 + (|β|²+|γ|²)/2, which bounds |αδ-βγ| from above.
        """
        return (abs(self.alpha)**2 + abs(self.delta)**2) / 2 + \
               (abs(self.beta)**2 + abs(self.gamma)**2) / 2

    def triangle_bound(self) -> float:
        """Compute the triangle inequality bound: |α|·|δ| + |β|·|γ|."""
        return abs(self.alpha) * abs(self.delta) + abs(self.beta) * abs(self.gamma)


def hopf_map_s7_to_s4(state: TwoQubitState) -> np.ndarray:
    """Map a normalized two-qubit state to S^4 via the quaternionic Hopf map.

    The Hopf map π: S^7 → S^4 sends (α, β, γ, δ) ∈ S^7 ⊂ ℂ^4 to a point in S^4.
    We use the standard construction:
        x₀ = |α|² + |β|² - |γ|² - |δ|²
        x₁ + ix₂ = 2(ᾱγ + β̄δ)
        x₃ + ix₄ = 2(ᾱδ - β̄γ)

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        state: A normalized TwoQubitState

    Returns:
        5D numpy array on S^4
    """
    a, b, g, d = state.alpha, state.beta, state.gamma, state.delta

    x0 = abs(a)**2 + abs(b)**2 - abs(g)**2 - abs(d)**2
    z1 = 2 * (np.conj(a) * g + np.conj(b) * d)
    z2 = 2 * (np.conj(a) * d - np.conj(b) * g)

    return np.array([x0, z1.real, z1.imag, z2.real, z2.imag])


def gauss_linking_integral(curve1: np.ndarray, curve2: np.ndarray) -> float:
    """Estimate the linking number of two closed curves via the Gauss linking integral.

    The Gauss linking integral computes:
        Lk(γ₁, γ₂) = (1/4π) ∮∮ (r₁ - r₂) · (dr₁ × dr₂) / |r₁ - r₂|³

    Time complexity: O(n²) where n is the number of sample points
    Space complexity: O(n)

    Args:
        curve1: (n, 3) array of points on the first curve
        curve2: (n, 3) array of points on the second curve

    Returns:
        Estimated linking number (should be close to an integer)
    """
    n1, n2 = len(curve1), len(curve2)
    total = 0.0

    for i in range(n1):
        r1 = curve1[i]
        dr1 = curve1[(i + 1) % n1] - curve1[i]

        for j in range(n2):
            r2 = curve2[j]
            dr2 = curve2[(j + 1) % n2] - curve2[j]

            diff = r1 - r2
            dist = np.linalg.norm(diff)
            if dist < 1e-12:
                continue

            cross = np.cross(dr1, dr2)
            total += np.dot(diff, cross) / dist**3

    return total / (4 * np.pi)


def compute_hopf_preimage_circle(base_point: np.ndarray, t_values: np.ndarray) -> np.ndarray:
    """Compute the Hopf preimage circle of a point on S^4.

    For a point p ∈ S^4, its preimage under the Hopf map π: S^7 → S^4 is a
    great circle in S^7. We parametrize this circle and project to ℝ³ for
    linking number computation.

    Time complexity: O(n) where n = len(t_values)

    Args:
        base_point: 5D point on S^4
        t_values: parameter values in [0, 2π]

    Returns:
        (n, 3) array of points on the preimage circle (projected to ℝ³)
    """
    x0, x1, x2, x3, x4 = base_point

    # Construct a point in the fiber
    r = np.sqrt(max(0, (1 + x0) / 2))
    s = np.sqrt(max(0, (1 - x0) / 2))

    if r > 1e-10:
        phase1 = 0.0
        if s > 1e-10:
            z_target = complex(x3, x4) / (2 * r * s) if r * s > 1e-10 else 0
            phase2 = np.angle(z_target)
        else:
            phase2 = 0.0
    else:
        phase1 = 0.0
        phase2 = 0.0

    points = []
    for t in t_values:
        # Parametrize the circle in the fiber
        p = np.array([
            r * np.cos(t + phase1),
            r * np.sin(t + phase1),
            s * np.cos(t + phase2),
            s * np.sin(t + phase2),
        ])
        # Project S^7 to ℝ³ via stereographic projection
        w = 1 - p[3] if abs(1 - p[3]) > 1e-10 else 1e-10
        proj = np.array([p[0] / w, p[1] / w, p[2] / w])
        points.append(proj)

    return np.array(points)


def test_hopf_entanglement_conjecture(n_states: int = 1000, n_points: int = 200) -> dict:
    """Test the Hopf-Entanglement Conjecture for random states.

    For each random normalized two-qubit state, compute:
    1. The concurrence C(ψ) = 2|αδ - βγ|
    2. The linking number of Hopf preimage circles

    The conjecture states these should be equal.

    Time complexity: O(n_states × n_points²)

    Args:
        n_states: Number of random states to test
        n_points: Number of points per curve for Gauss integral

    Returns:
        Dictionary with test results
    """
    results = {
        'concurrences': [],
        'linking_numbers': [],
        'differences': [],
        'n_states': n_states,
    }

    t_values = np.linspace(0, 2 * np.pi, n_points, endpoint=False)

    for _ in range(n_states):
        state = TwoQubitState.random_normalized()
        c = state.concurrence()

        # Map to S^4
        s4_point = hopf_map_s7_to_s4(state)

        # Choose two nearby points on S^4
        perturbation = np.random.randn(5) * 0.1
        p1 = s4_point + perturbation
        p1 = p1 / np.linalg.norm(p1)

        perturbation2 = np.random.randn(5) * 0.1
        p2 = s4_point + perturbation2
        p2 = p2 / np.linalg.norm(p2)

        # Compute preimage circles and linking number
        circle1 = compute_hopf_preimage_circle(p1, t_values)
        circle2 = compute_hopf_preimage_circle(p2, t_values)
        lk = gauss_linking_integral(circle1, circle2)

        results['concurrences'].append(c)
        results['linking_numbers'].append(abs(lk))
        results['differences'].append(abs(c - abs(lk)))

    results['mean_difference'] = np.mean(results['differences'])
    results['max_difference'] = np.max(results['differences'])
    results['correlation'] = np.corrcoef(results['concurrences'],
                                          results['linking_numbers'])[0, 1]

    return results


if __name__ == '__main__':
    print("Running Hopf-Entanglement Conjecture Test...")
    print("(Note: linking number computation is approximate)")
    print()

    # Quick test with fewer states
    results = test_hopf_entanglement_conjecture(n_states=100, n_points=100)

    print(f"States tested: {results['n_states']}")
    print(f"Mean |C - |Lk||: {results['mean_difference']:.4f}")
    print(f"Max |C - |Lk||: {results['max_difference']:.4f}")
    print(f"Correlation: {results['correlation']:.4f}")
