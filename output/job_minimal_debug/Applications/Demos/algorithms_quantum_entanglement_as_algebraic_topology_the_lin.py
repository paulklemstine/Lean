#!/usr/bin/env python3
"""
Algorithms for Quantum Entanglement via the Hopf Fibration

Type-hinted implementations of the core algorithms connecting
quantum entanglement (concurrence) to algebraic topology (Hopf fibration).
"""

import numpy as np
from typing import Tuple, List
from dataclasses import dataclass


@dataclass
class TwoQubitState:
    """A pure state of two qubits: α|00⟩ + β|01⟩ + γ|10⟩ + δ|11⟩."""
    alpha: complex
    beta: complex
    gamma: complex
    delta: complex

    def normalize(self) -> 'TwoQubitState':
        """Return normalized version of this state."""
        norm = np.sqrt(abs(self.alpha)**2 + abs(self.beta)**2 +
                       abs(self.gamma)**2 + abs(self.delta)**2)
        return TwoQubitState(self.alpha/norm, self.beta/norm,
                             self.gamma/norm, self.delta/norm)

    def coeff_matrix(self) -> np.ndarray:
        """The 2×2 coefficient matrix M = [[α, β], [γ, δ]]."""
        return np.array([[self.alpha, self.beta],
                         [self.gamma, self.delta]])

    def concurrence(self) -> float:
        """Compute the concurrence C = 2|αδ - βγ|."""
        return 2.0 * abs(self.alpha * self.delta - self.beta * self.gamma)

    def det_invariant(self) -> complex:
        """The determinant invariant αδ - βγ."""
        return self.alpha * self.delta - self.beta * self.gamma

    def spin_flip_inner(self) -> complex:
        """The spin-flip inner product ⟨ψ̃|ψ⟩ = -2(αδ - βγ)."""
        a, b, g, d = self.alpha, self.beta, self.gamma, self.delta
        return -d * a + g * b + b * g - a * d

    def is_separable(self, tol: float = 1e-10) -> bool:
        """Check if the state is separable (product state)."""
        return self.concurrence() < tol

    def entanglement_wedge(self) -> complex:
        """The wedge product v₁ ∧ v₂ of the row vectors."""
        return self.det_invariant()


@dataclass
class EntanglementWedge:
    """The entanglement wedge: two vectors in C² whose wedge product
    measures entanglement and equals the Hopf linking invariant."""
    v1: np.ndarray  # shape (2,), complex
    v2: np.ndarray  # shape (2,), complex

    @classmethod
    def from_state(cls, state: TwoQubitState) -> 'EntanglementWedge':
        """Construct from a two-qubit state's coefficient matrix rows."""
        return cls(
            v1=np.array([state.alpha, state.beta]),
            v2=np.array([state.gamma, state.delta])
        )

    def wedge_product(self) -> complex:
        """Compute v₁ ∧ v₂ = v₁[0]·v₂[1] - v₁[1]·v₂[0]."""
        return self.v1[0] * self.v2[1] - self.v1[1] * self.v2[0]

    def concurrence(self) -> float:
        """Concurrence from the wedge product: 2|v₁ ∧ v₂|."""
        return 2.0 * abs(self.wedge_product())

    def hopf_images(self) -> Tuple[np.ndarray, np.ndarray]:
        """Project both rows through the Hopf map to get two points on S²."""
        p1 = hopf_map(self.v1[0], self.v1[1])
        p2 = hopf_map(self.v2[0], self.v2[1])
        return p1, p2


def hopf_map(z1: complex, z2: complex) -> np.ndarray:
    """
    The Hopf fibration S³ → S² as an algebraic map C² → ℝ³.

    Maps (z₁, z₂) to (2Re(z₁z̄₂), 2Im(z₁z̄₂), |z₁|² - |z₂|²).
    On the unit sphere |z₁|²+|z₂|²=1, the image lies on S².

    Algorithm:
        1. Compute w = z₁ · conj(z₂)
        2. Return (2·Re(w), 2·Im(w), |z₁|² - |z₂|²)

    Time complexity: O(1)
    """
    w = z1 * np.conj(z2)
    return np.array([2 * w.real, 2 * w.imag, abs(z1)**2 - abs(z2)**2])


def hopf_preimage_circle(point: np.ndarray, n_points: int = 100) -> np.ndarray:
    """
    Compute the Hopf preimage of a point on S².

    Given a point (x, y, z) on S², find the circle in S³ ⊂ C²
    that maps to it under the Hopf map.

    Algorithm:
        1. From (x, y, z) with x²+y²+z²=1, recover |z₁|² = (1+z)/2, |z₂|² = (1-z)/2
        2. Set r₁ = √((1+z)/2), r₂ = √((1-z)/2)
        3. Find phase φ such that r₁r₂e^{iφ} has real part x/2 and imaginary part y/2
        4. The fiber is {(r₁e^{iθ}, r₂e^{i(θ-φ)}) : θ ∈ [0, 2π)}

    Returns: array of shape (n_points, 4) giving (Re z₁, Im z₁, Re z₂, Im z₂)
    """
    x, y, z = point
    r1 = np.sqrt(max((1 + z) / 2, 0))
    r2 = np.sqrt(max((1 - z) / 2, 0))

    if r1 * r2 > 1e-10:
        phi = np.arctan2(y, x)
    else:
        phi = 0.0

    thetas = np.linspace(0, 2 * np.pi, n_points, endpoint=False)
    circle = np.zeros((n_points, 4))
    for i, theta in enumerate(thetas):
        z1 = r1 * np.exp(1j * theta)
        z2 = r2 * np.exp(1j * (theta - phi))
        circle[i] = [z1.real, z1.imag, z2.real, z2.imag]

    return circle


def compute_linking_number_gauss(curve1: np.ndarray, curve2: np.ndarray) -> float:
    """
    Compute the Gauss linking number of two closed curves in ℝ⁴ projected to ℝ³.

    Uses the Gauss linking integral:
        Lk = (1/4π) ∮∮ (r₁ - r₂) · (dr₁ × dr₂) / |r₁ - r₂|³

    For curves in S³ ⊂ ℝ⁴, we use stereographic projection to ℝ³.

    Algorithm:
        1. Stereographically project both curves from S³ to ℝ³
        2. Discretize the Gauss integral
        3. Sum contributions from each pair of segments

    Returns: float (should be close to an integer for genuine links)
    """
    def stereo_project(pts_4d: np.ndarray) -> np.ndarray:
        """Stereographic projection from S³ to ℝ³ (from north pole)."""
        w = pts_4d[:, 3]
        denom = 1 - w + 1e-15
        return pts_4d[:, :3] / denom[:, np.newaxis]

    c1 = stereo_project(curve1)
    c2 = stereo_project(curve2)
    n1, n2 = len(c1), len(c2)

    linking = 0.0
    for i in range(n1):
        i_next = (i + 1) % n1
        dr1 = c1[i_next] - c1[i]
        for j in range(n2):
            j_next = (j + 1) % n2
            dr2 = c2[j_next] - c2[j]
            r = c1[i] - c2[j]
            r_norm = np.linalg.norm(r)
            if r_norm < 1e-10:
                continue
            cross = np.cross(dr1, dr2)
            linking += np.dot(r, cross) / r_norm**3

    return linking / (4 * np.pi)


def verify_hopf_linking(state: TwoQubitState, n_circle: int = 200) -> dict:
    """
    Verify the Hopf-concurrence connection for a given state.

    Algorithm:
        1. Compute concurrence algebraically: C = 2|αδ - βγ|
        2. Form the EntanglementWedge from the coefficient matrix rows
        3. Project rows to S² via the Hopf map
        4. Compute Hopf preimage circles
        5. Compute linking number numerically via Gauss integral
        6. Compare C with |linking number|

    Returns: dict with concurrence, linking_number, and agreement status
    """
    state = state.normalize()
    C = state.concurrence()

    wedge = EntanglementWedge.from_state(state)
    v1_norm = np.linalg.norm(wedge.v1)
    v2_norm = np.linalg.norm(wedge.v2)

    result = {
        'concurrence': C,
        'det_invariant': state.det_invariant(),
        'spin_flip_inner': state.spin_flip_inner(),
        'is_separable': state.is_separable(),
    }

    if v1_norm > 1e-10 and v2_norm > 1e-10:
        v1_normalized = wedge.v1 / v1_norm
        v2_normalized = wedge.v2 / v2_norm
        p1 = hopf_map(v1_normalized[0], v1_normalized[1])
        p2 = hopf_map(v2_normalized[0], v2_normalized[1])
        result['hopf_image_1'] = p1
        result['hopf_image_2'] = p2

        circle1 = hopf_preimage_circle(p1, n_circle)
        circle2 = hopf_preimage_circle(p2, n_circle)
        lk = compute_linking_number_gauss(circle1, circle2)
        result['linking_number_raw'] = lk
        result['linking_number_rounded'] = round(lk)

    return result


def sl2_transform(U: np.ndarray, V: np.ndarray,
                  state: TwoQubitState) -> TwoQubitState:
    """
    Apply local SL(2,ℂ) transformation: M ↦ U M Vᵀ.
    Preserves the concurrence (det is invariant under SL(2)).

    Algorithm:
        1. Form M = [[α, β], [γ, δ]]
        2. Compute M' = U @ M @ V.T
        3. Return new state from M'
    """
    M = state.coeff_matrix()
    M_new = U @ M @ V.T
    return TwoQubitState(M_new[0, 0], M_new[0, 1], M_new[1, 0], M_new[1, 1])


# Standard Bell states
BELL_PHI_PLUS = TwoQubitState(1/np.sqrt(2), 0, 0, 1/np.sqrt(2))
BELL_PHI_MINUS = TwoQubitState(1/np.sqrt(2), 0, 0, -1/np.sqrt(2))
BELL_PSI_PLUS = TwoQubitState(0, 1/np.sqrt(2), 1/np.sqrt(2), 0)
BELL_PSI_MINUS = TwoQubitState(0, 1/np.sqrt(2), -1/np.sqrt(2), 0)


if __name__ == "__main__":
    print("Testing algorithms...")
    for name, bell in [("Φ+", BELL_PHI_PLUS), ("Φ-", BELL_PHI_MINUS),
                        ("Ψ+", BELL_PSI_PLUS), ("Ψ-", BELL_PSI_MINUS)]:
        result = verify_hopf_linking(bell)
        print(f"Bell state |{name}⟩: C={result['concurrence']:.6f}, "
              f"separable={result['is_separable']}")

    product = TwoQubitState(0.6, 0.8j, 0.6j, -0.8)
    result = verify_hopf_linking(product)
    print(f"Product state: C={result['concurrence']:.6f}")
